import gdb
import gdb.types
import itertools
import re

log_file = None
GDB_FLATTENED_CHILDREN_WORKAROUND = False
CHILDREN_MAX_RECURSION_LEVEL = 0

# workaround: don't cast the following DOHs to it's actual type
# to avoid infinite pretty-print loops
cast_black_list = {
  'Hash': set(['parentNode', 'symtab', 'csymtab', 'sym:symtab', 'inherit', 'nextSibling', 'previousSibling'])
}

def print_(msg):
    global log_file;
    
    if True:
      if log_file == None:
        log_file = open('swig_gdb.log', 'w')
      log_file.write(msg)

    print(msg)
  
class SwigStringPrinter:
  """
    Pretty print Swig String* types.
  """

  def __init__ (self, typename, val):
    self.typename = typename
    self.val = val
    
    try:
      self.t_swigstr_ptr = gdb.lookup_type("struct String").pointer()
      self.t_doh_base_ptr = gdb.lookup_type("DohBase").pointer()
    except Exception as err:
      print_("SwigStringPrinter: Could not retrieve gdb types.\n  %s.\n"%(str(err)))

  def display_hint(self):
    return 'string'

  def to_string(self):
    ret = "<invalid>"

    # Conversion taken from Swig Internals manual:
    # http://peregrine.hpc.uwm.edu/Head-node-docs/swig/2.0.4/Devel/internals.html#7
    # (*(struct String *)(((DohBase *)s)->data)).str
    
    dohbase = None;
    str_data = None;
    char_ptr = None;
    
    try:
      dohbase = self.val.reinterpret_cast(self.t_doh_base_ptr).dereference()
    except Exception as err:
      print_("SwigStringPrinter: Could not dereference DOHBase*\n");
      return "<invalid>";
      
    try:
      str_data = dohbase['data'].reinterpret_cast(self.t_swigstr_ptr).dereference()
    except Exception as err:
      print_("SwigStringPrinter: Could not dereference struct String*\n");
      return "<invalid>";
      
    try:
      char_ptr = str_data['str']
    except Exception as err:
      print_("SwigStringPrinter: Could not access field (struct String).str\n");
      return "<invalid>";
      
    if char_ptr.is_lazy is True:
      char_ptr.fetch_lazy ()
    
    try:
      ret = char_ptr.string()
    except Exception as err:
      print_("SwigStringPrinter: Could not convert const char* to string\n");
      return "<invalid>";
        
    return ret

class SwigIterator:
  
  def __init__(self):
    
    self.t_doh_base_ptr = gdb.lookup_type("DohBase").pointer()
    self.t_string_ptr = gdb.lookup_type("String").pointer()
    self.t_node_ptr = gdb.lookup_type("Node").pointer()
    self.t_hash_ptr = gdb.lookup_type("Hash").pointer()
    self.t_file_ptr = gdb.lookup_type("File").pointer()
    self.t_void_ptr = gdb.lookup_type("void").pointer()

  def cast_doh(self, doh, name = None):
                
    if doh == 0:
      return doh
      
    doh = doh.reinterpret_cast(self.t_doh_base_ptr);
    
    val_base = doh.dereference()
    val_type = val_base['type'].dereference()
    val_typestr = val_type['objname'].string()
    
    if not name == None and val_typestr in cast_black_list:
      blacklist = cast_black_list[val_typestr]
      if name in blacklist:
        return doh
    
    if "String" == val_typestr:
      doh = doh.reinterpret_cast(self.t_string_ptr)
    elif "File" == val_typestr:
      doh = doh.reinterpret_cast(self.t_file_ptr)
    # BUG: GDB Pyhton can not handle cyclic references yet
    #      so these casts are deactivated
    elif "Hash" == val_typestr:
      doh = doh.reinterpret_cast(self.t_hash_ptr)
    elif "Node" == val_typestr:
      doh = doh.reinterpret_cast(self.t_node_ptr)

    return doh

class SwigListIterator(SwigIterator):

  def __init__(self, val):
    SwigIterator.__init__(self);

    try:
      self.valid = False

      self.val = val.reinterpret_cast(self.t_doh_base_ptr)
      val_base = self.val.dereference()
      val_type = val_base['type'].dereference()
      val_typestr = val_type['objname'].string()
      #print_("SwigListIterator: constructing iterator for value of type %s"%val_typestr)

      self.t_struct_list_ptr = gdb.lookup_type("struct List").pointer()

      doh_base = self.val.dereference()
      self.l = doh_base['data'].reinterpret_cast(self.t_struct_list_ptr).dereference()

      self.address = 0
      self._index = 0
      self.key = 0
      self.item = 0

      self.address = self.val.dereference().address

      self.is_first = True
      self.valid = True

    except Exception as err:
      print_("SwigListIterator: Construction failed.\n %s.\n"%(str(err)))

  def __iter__(self):
    return self

  def List_first(self):
    
    self.object = None;
    self._index = 0
    self.key = 0
    self.nitems = int(self.l['nitems'])
    self.items = self.l['items']
    
    if self.nitems > 0:
        self.item = self.items[0]
    else:
      self.stop()
  
  def List_next(self):
    self._index = self._index + 1
    if self._index >= self.nitems:
      self.stop()
    else:
      self.item = self.items[self._index]
      
  def next(self):

    if not self.valid:
      self.stop()
      
    if self.is_first:
      self.is_first = False
      try:
        self.List_first()
      except StopIteration:
        raise StopIteration
      except Exception as err:
        print_("Error during iteration to first node: \n %s \n" %(str(err)))
        self.stop()
    else:
      try:
        self.List_next()
      except StopIteration:
        raise StopIteration
      except Exception as err:
        print_("Error during iteration to first node: \n %s \n" %(str(err)))
        self.stop()
      
    key_str = "[%d]"%self._index
    item = 0

    try:
      item = self.cast_doh(self.item)
    except Exception as err:
      print_("SwigListIterator(%s): Exception during casting of value doh:\n %s\n" % (str(self.address), str(err)) )
      self.stop()

    return (key_str, item)

  def stop(self):
    self.is_first = True
    self.item = 0
    self.key = 0
    raise StopIteration      

class SwigHashIterator(SwigIterator):

  def __init__(self, val):
    SwigIterator.__init__(self);

    try:
      self.valid = False
            
      self.val = val.reinterpret_cast(self.t_doh_base_ptr)

      self.t_struct_hash_ptr = gdb.lookup_type("struct Hash").pointer()
      self.t_struct_hash_node_ptr = gdb.lookup_type("struct HashNode").pointer()

      doh_base = self.val.dereference()
      hash_ = doh_base['data'].reinterpret_cast(self.t_struct_hash_ptr).dereference()
      self.hashtable = hash_['hashtable']
      self.hashsize = int(hash_['hashsize'])
      self.nitems = int(hash_['nitems'])      

      self.next_ = 0
      self.address = 0
      self.pos = 0;
      self._current = 0
      self.item = 0
      self.key = 0
      self._index = 0
      
      self.address = self.val.dereference().address

      self.is_first = True
      self.valid = True

    except Exception as err:
      print_("SwigHashIterator: Construction failed.\n %s.\n"%(str(err)))
  
  def __iter__(self):
    return self
      
  def Hash_firstiter(self):
    self._current = 0;
    self.item = 0;
    self.key = 0;
    self._index = 0;    

    while (self._index < self.hashsize) and (self.hashtable[self._index] == 0):
      self._index = self._index+1;

    if self._index >= self.hashsize:
      self.stop();

    self._current = self.hashtable[self._index]
    self._current = self._current.reinterpret_cast(self.t_struct_hash_node_ptr);
    self.item = self._current['object'];
    self.key = self._current['key'];

    self._current = self._current['next'];
  
  
  def Hash_nextiter(self):
    if self._current == 0:
      self._index = self._index + 1
      while (self._index < self.hashsize) and (self.hashtable[self._index] == 0):
        self._index = self._index + 1

      if self._index >= self.hashsize:
        self.item = 0;
        self.key = 0;
        self._current = 0;
        self.stop()

      self._current = self.hashtable[self._index];

    self._current = self._current.reinterpret_cast(self.t_struct_hash_node_ptr);
    self.key = self._current['key'];
    self.item = self._current['object'];

    self._current = self._current['next'];
    

  def next(self):

    if not self.valid:
      self.stop()
      
    if self.is_first:
      self.is_first = False
      try:
        self.Hash_firstiter()
      except StopIteration:
        raise StopIteration
      except Exception as err:
        print_("Error during iteration to first node: \n %s \n" %(str(err)))
        self.stop()
    else:
      try:
        self.Hash_nextiter()
      except StopIteration:
        raise StopIteration
      except Exception as err:
        print_("Error during iteration to first node: \n %s \n" %(str(err)))
        self.stop()
      
    key_str = "<err>"
    item = 0
    try:
      string_printer = SwigStringPrinter("String *", self.key)
      key_str = string_printer.to_string()
    except Exception as err:
      print_("SwigHashIterator(%s): Exception during extracting key string:\n %s\n" % (str(self.address), str(err)) )
      self.stop()

    try:
      item = self.cast_doh(self.item, key_str)
      
    except Exception as err:
      print_("SwigHashIterator(%s): Exception during casting of value doh:\n %s\n" % (str(self.address), str(err)) )
      self.stop()

    return (key_str, item)
  
  def stop(self):
    self.is_first = True
    raise StopIteration      

class AlternateKeyValueIterator():

  def __init__(self, iterable):
    self.it = iterable.__iter__()
    self._next = None
    self.count = -1

  def __iter__(self):
    return self

  def next(self):
    if self._next == None:
      key, value = self.it.next()
      self._next = value
      self.count = self.count + 1
      return ("[%d]"%self.count, key)
    else:
      value = self._next
      self._next = None
      return ("[%d]"%self.count, value)

class NopIterator:
  
  def __init__(self):
    pass
  
  def __iter__(self):
    return self
    
  def next(self):
    raise StopIteration

class SwigListPrinter:
  """
    Pretty print Swig List* types (also ParmList*).
  """
    
  def __init__ (self, typename, val):
    
    self.typename = typename
    self.val = val
    
    it = SwigListIterator(val)
    self.valid = it.valid
    self.address = it.address
      
     
  def display_hint(self):
    return 'array'

  def to_string(self):
    return "%s(%s)" % (str(self.typename), str(self.address))
        
  def children(self):
        
    if not self.valid:
      print_("SwigListPrinter: Invalid state.\n")
      return NopIterator()
    
    try:
      it = SwigListIterator(self.val)
      return it
    except Exception as err:
      print_("SwigListPrinter: Error during creation of children iterator. \n %s \n" %(str(err)))
      raise err

class SwigHashPrinter:
  """
    Pretty print Swig Hash* types (also Node*).
  """
    
  def __init__ (self, typename, val):
    
    self.typename = typename
    self.val = val
    it = SwigHashIterator(val)
    self.valid = it.valid
    self.address = it.address
    self.level = 0;
         
  def display_hint(self):
    return 'map'

  def to_string(self):
    return "%s(%s)" % (str(self.typename), str(self.address))
        
  def children(self):
    global GDB_FLATTENED_CHILDREN_WORKAROUND
    global CHILDREN_MAX_RECURSION_LEVEL
    
    if not self.valid:
      print_("SwigHashPrinter: Invalid state.\n")
      return NopIterator()
      
    if self.level > CHILDREN_MAX_RECURSION_LEVEL:
      return NopIterator()
    
    try:
      it = SwigHashIterator(self.val)
      if GDB_FLATTENED_CHILDREN_WORKAROUND:
        return AlternateKeyValueIterator(it)
      return it
    except Exception as err:
      print_("SwigHashPrinter: Error during creation of children iterator. \n %s \n" %(str(err)))
      raise err
      
class SwigSimplePrinter:
  def __init__ (self, typename, val):
    self.typename = typename
    self.val = val
    
  def display_hint(self):
    return "string"

  def to_string(self):
    return "%s(%s)"%(self.typename, str(self.val.address))
  
class SwigDelegatingPrinter:

  def __init__ (self, typename, val):
      t_doh_base_ptr = gdb.lookup_type("DohBase").pointer()
      val_base = val.reinterpret_cast(t_doh_base_ptr).dereference()
      val_type = val_base['type'].dereference()
      val_typestr = val_type['objname'].string()
      self.has_children = False
      
      if val_typestr == "Hash":
        self.delegate = SwigHashPrinter(typename, val)
        self.has_children = True
      elif val_typestr == "List":
        self.delegate = SwigListPrinter(typename, val)
        self.has_children = True
      elif val_typestr == "String":
        self.delegate = SwigStringPrinter(typename, val)
      else:
        self.delegate = SwigSimplePrinter(typename, val)

  def display_hint(self):
    return self.delegate.display_hint()

  def to_string(self):
    return self.delegate.to_string()

  def children(self):
    if not self.has_children:
      return NopIterator()
      
    return self.delegate.children()

class RxPrinter(object):
    def __init__(self, name, function):
        super(RxPrinter, self).__init__()
        self.name = name
        self.function = function
        self.enabled = True

    def invoke(self, value):
        if not self.enabled:
            return None
        return self.function(self.name, value)

# A pretty-printer that conforms to the "PrettyPrinter" protocol from
# gdb.printing.  It can also be used directly as an old-style printer.
class Printer(object):
    def __init__(self, name):
        super(Printer, self).__init__()
        self.name = name
        self.subprinters = []
        self.lookup = {}
        self.enabled = True
        self.compiled_rx = re.compile('^([a-zA-Z0-9_: *]+)$')

    def add(self, name, function):        
        if not self.compiled_rx.match(name):
            raise ValueError, 'error: "%s" does not match' % name
        
        printer = RxPrinter(name, function)
        self.subprinters.append(printer)
        self.lookup[name] = printer
        print('Added pretty printer for %s. ' % (name))

    def __call__(self, val):
        typename = str(val.type)
        if typename in self.lookup:
            ret = self.lookup[typename].invoke(val)
            return ret

        # Cannot find a pretty printer.  Return None.
        return None

swig_printer = None

def register_swig_printers(obj):
    global swig_printer

    if obj is None:
      obj = gdb

    obj.pretty_printers.append(swig_printer)

def build_swig_printer():
    global swig_printer

    swig_printer = Printer("swig")
    swig_printer.add('String *', SwigStringPrinter)
    swig_printer.add('const String *', SwigStringPrinter)
    swig_printer.add('SwigType *', SwigStringPrinter)
    swig_printer.add('Hash *', SwigHashPrinter)
    swig_printer.add('const Hash *', SwigHashPrinter)
    swig_printer.add('Node *', SwigHashPrinter)
    swig_printer.add('const Node *', SwigHashPrinter)
    swig_printer.add('Parm *', SwigHashPrinter)
    swig_printer.add('const Parm *', SwigHashPrinter)
    swig_printer.add('List *', SwigListPrinter)
    swig_printer.add('const List *', SwigListPrinter)
    swig_printer.add('ParmList *', SwigDelegatingPrinter)
    swig_printer.add('const ParmList *', SwigDelegatingPrinter)
    swig_printer.add('File *', SwigDelegatingPrinter)
    #swig_printer.add('DOH *', SwigDelegatingPrinter)
    #swig_printer.add('const DOH *', SwigDelegatingPrinter)
    
    print_("Loaded swig printers\n");

def enableGdbPrintWorkaround():
  global GDB_FLATTENED_CHILDREN_WORKAROUND
  GDB_FLATTENED_CHILDREN_WORKAROUND = True

def setChildrenRecursionLevel(level):
  global CHILDREN_MAX_RECURSION_LEVEL
  CHILDREN_MAX_RECURSION_LEVEL = level

build_swig_printer()

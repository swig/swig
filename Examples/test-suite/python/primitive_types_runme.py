from primitive_types import *

var_init()

# assigning globals calls
cvar.var_bool = sct_bool
cvar.var_schar = sct_schar
cvar.var_uchar = sct_uchar
cvar.var_int = sct_int
cvar.var_uint = sct_uint
cvar.var_short = sct_short
cvar.var_ushort = sct_ushort
cvar.var_long = sct_long
cvar.var_ulong = sct_ulong
cvar.var_llong = sct_llong
cvar.var_ullong = sct_ullong
cvar.var_float = sct_float
cvar.var_double = sct_double
cvar.var_char = sct_char
cvar.var_pchar = sct_pchar
cvar.var_pcharc = sct_pcharc
cvar.var_pint = sct_pint
cvar.var_sizet = sct_sizet
cvar.var_hello = sct_hello
cvar.var_myint = sct_myint
cvar.var_namet = def_namet
cvar.var_parami = sct_parami
cvar.var_paramd = sct_paramd
cvar.var_paramc = sct_paramc

v_check()

def pyerror(name, val, cte):
  print "bad val/cte", name, val, cte
  raise RuntimeError
  pass

if cvar.var_bool != cct_bool: pyerror("bool", cvar.var_bool, cct_bool)
if cvar.var_schar != cct_schar: pyerror("schar", cvar.var_schar, cct_schar)
if cvar.var_uchar != cct_uchar: pyerror("uchar", cvar.var_uchar, cct_uchar)
if cvar.var_int != cct_int: pyerror("int", cvar.var_int, cct_int)
if cvar.var_uint != cct_uint: pyerror("uint", cvar.var_uint, cct_uint)
if cvar.var_short != cct_short: pyerror("short", cvar.var_short, cct_short)
if cvar.var_ushort != cct_ushort: pyerror("ushort", cvar.var_ushort, cct_ushort)
if cvar.var_long != cct_long: pyerror("long", cvar.var_long, cct_long)
if cvar.var_ulong != cct_ulong: pyerror("ulong", cvar.var_ulong, cct_ulong)
if cvar.var_llong != cct_llong: pyerror("llong", cvar.var_llong, cct_llong)
if cvar.var_ullong != cct_ullong: pyerror("ullong", cvar.var_ullong, cct_ullong)
if cvar.var_float != cct_float: pyerror("float", cvar.var_float, cct_float)
if cvar.var_double != cct_double: pyerror("double", cvar.var_double, cct_double)
if cvar.var_char != cct_char: pyerror("char", cvar.var_char, cct_char)
if cvar.var_pchar != cct_pchar: pyerror("pchar", cvar.var_pchar, cct_pchar)
if cvar.var_pcharc != cct_pcharc: pyerror("pchar", cvar.var_pcharc, cct_pcharc)
if cvar.var_pint != cct_pint: pyerror("pint", cvar.var_pint, cct_pint)
if cvar.var_sizet != cct_sizet: pyerror("sizet", cvar.var_sizet, cct_sizet)
if cvar.var_hello != cct_hello: pyerror("hello", cvar.var_hello, cct_hello)
if cvar.var_myint != cct_myint: pyerror("myint", cvar.var_myint, cct_myint)
if cvar.var_namet != def_namet: pyerror("name", cvar.var_namet, def_namet)

class PyTest (TestDirector):
  def __init__(self):
    TestDirector.__init__(self)
    pass
  def ident(self, x):
    return x
  
  def vval_bool(self, x): return self.ident(x)
  def vval_schar(self, x): return self.ident(x)
  def vval_uchar(self, x): return self.ident(x)
  def vval_int(self, x): return self.ident(x)
  def vval_uint(self, x): return self.ident(x)
  def vval_short(self, x): return self.ident(x)
  def vval_ushort(self, x): return self.ident(x)
  def vval_long(self, x): return self.ident(x)
  def vval_ulong(self, x): return self.ident(x)
  def vval_llong(self, x): return self.ident(x)
  def vval_ullong(self, x): return self.ident(x)
  def vval_float(self, x): return self.ident(x)
  def vval_double(self, x): return self.ident(x)
  def vval_char(self, x): return self.ident(x)
  def vval_pchar(self, x): return self.ident(x)
  def vval_pcharc(self, x): return self.ident(x)
  def vval_pint(self, x): return self.ident(x)
  def vval_sizet(self, x): return self.ident(x)
  def vval_hello(self, x): return self.ident(x)
  def vval_myint(self, x): return self.ident(x)

  def vref_bool(self, x): return self.ident(x)
  def vref_schar(self, x): return self.ident(x)
  def vref_uchar(self, x): return self.ident(x)
  def vref_int(self, x): return self.ident(x)
  def vref_uint(self, x): return self.ident(x)
  def vref_short(self, x): return self.ident(x)
  def vref_ushort(self, x): return self.ident(x)
  def vref_long(self, x): return self.ident(x)
  def vref_ulong(self, x): return self.ident(x)
  def vref_llong(self, x): return self.ident(x)
  def vref_ullong(self, x): return self.ident(x)
  def vref_float(self, x): return self.ident(x)
  def vref_double(self, x): return self.ident(x)
  def vref_char(self, x): return self.ident(x)
  def vref_pchar(self, x): return self.ident(x)
  def vref_pcharc(self, x): return self.ident(x)
  def vref_pint(self, x): return self.ident(x)
  def vref_sizet(self, x): return self.ident(x)
  def vref_hello(self, x): return self.ident(x)
  def vref_myint(self, x): return self.ident(x)

  pass


t = Test()
p = PyTest()


# internal call check
if t.c_check() != p.c_check():
  raise RuntimeError, "bad director"

p.var_bool = p.stc_bool
p.var_schar = p.stc_schar
p.var_uchar = p.stc_uchar
p.var_int = p.stc_int
p.var_uint = p.stc_uint
p.var_short = p.stc_short
p.var_ushort = p.stc_ushort
p.var_long = p.stc_long
p.var_ulong = p.stc_ulong
p.var_llong = p.stc_llong
p.var_ullong = p.stc_ullong
p.var_float = p.stc_float
p.var_double = p.stc_double
p.var_char = p.stc_char
p.var_pchar = sct_pchar
p.var_pcharc = sct_pcharc
p.var_pint = sct_pint
p.var_sizet = sct_sizet
p.var_hello = sct_hello
p.var_myint = sct_myint
p.var_namet = def_namet
p.var_parami = sct_parami
p.var_paramd = sct_paramd
p.var_paramc = sct_paramc

p.v_check()


t.var_bool = t.stc_bool
t.var_schar = t.stc_schar
t.var_uchar = t.stc_uchar
t.var_int = t.stc_int
t.var_uint = t.stc_uint
t.var_short = t.stc_short
t.var_ushort = t.stc_ushort
t.var_long = t.stc_long
t.var_ulong = t.stc_ulong
t.var_llong = t.stc_llong
t.var_ullong = t.stc_ullong
t.var_float = t.stc_float
t.var_double = t.stc_double
t.var_char = t.stc_char
t.var_pchar = sct_pchar
t.var_pcharc = sct_pcharc
t.var_pint = sct_pint
t.var_sizet = sct_sizet
t.var_hello = sct_hello
t.var_myint = sct_myint
t.var_namet = def_namet
t.var_parami = sct_parami
t.var_paramd = sct_paramd
t.var_paramc = sct_paramc

t.v_check()

# this value contains a '0' char!
if def_namet != 'ho\0la':
  print "bad namet", def_namet
  raise RuntimeError

t.var_namet = def_namet
if t.var_namet != def_namet:
  print "bad namet", t.var_namet, def_namet
  raise RuntimeError

t.var_namet = 'holac'

if t.var_namet != 'holac':
  print "bad namet", t.var_namet
  raise RuntimeError

t.var_namet = 'hol'

if t.var_namet != 'hol':
#if t.var_namet != 'hol\0\0':
  print "bad namet", t.var_namet
  raise RuntimeError


if t.strlen('hile') != 4:
  print t.strlen('hile')
  raise RuntimeError, "bad string typemap"

if t.strlen('hil\0') != 4:
  raise RuntimeError, "bad string typemap"


cvar.var_char = '\0'
if cvar.var_char != '\0':
  raise RuntimeError, "bad char '0' case"
  
cvar.var_char = 0
if cvar.var_char != '\0':
  raise RuntimeError, "bad char '0' case"

cvar.var_namet = '\0'
#if cvar.var_namet != '\0\0\0\0\0':
if cvar.var_namet != '':
  print 'hola', '', cvar.var_namet
  raise RuntimeError, "bad char '\0' case"

cvar.var_namet = ''
#if cvar.var_namet != '\0\0\0\0\0':
if cvar.var_namet != '':
  raise RuntimeError, "bad char empty case"

cvar.var_pchar = None
if cvar.var_pchar != None:
  raise RuntimeError, "bad None case"

cvar.var_pchar = ''
if cvar.var_pchar != '':
  print '%c' % (cvar.var_pchar[0],)
  raise RuntimeError, "bad char empty case"

cvar.var_pcharc = None
if cvar.var_pcharc != None:
  raise RuntimeError, "bad None case"

cvar.var_pcharc = ''
if cvar.var_pcharc != '':
  raise RuntimeError, "bad char empty case"


#
# creating a raw char*
#
pc = new_pchar(5)
pchar_setitem(pc, 0, 'h')
pchar_setitem(pc, 1, 'o')
pchar_setitem(pc, 2, 'l')
pchar_setitem(pc, 3, 'a')
pchar_setitem(pc, 4, 0)


if t.strlen(pc) != 4:
  raise RuntimeError, "bad string typemap"

cvar.var_pchar = pc
if cvar.var_pchar != "hola":
  print cvar.var_pchar
  raise RuntimeError, "bad pointer case"

cvar.var_namet = pc
#if cvar.var_namet != "hola\0":
if cvar.var_namet != "hola":
  raise RuntimeError, "bad pointer case"

delete_pchar(pc)

#
# Now when things should fail
#


try:
  error = 0
  a = t.var_uchar
  t.var_uchar = 10000
  error = 1
except OverflowError:
  if a != t.var_uchar:
    error = 1
  pass
if error:
  raise RuntimeError, "bad uchar typemap"



try:
  error = 0
  a = t.var_char
  t.var_char = '23'
  error = 1
except TypeError:
  if a != t.var_char:
    error = 1
  pass 
if error:
  raise RuntimeError, "bad char typemap"

try:
  error = 0
  a = t.var_uint
  t.var_uint = -1
  error = 1
except OverflowError:
  if a != t.var_uint:
    error = 1
  pass 
if error:
  raise RuntimeError, "bad uint typemap"

#
#
try:
  error = 0
  a = t.var_namet
  t.var_namet = '123456'
  error = 1
except TypeError:
  if a != t.var_namet:
    error = 1
  pass 
if error:
  raise RuntimeError, "bad namet typemap"

#
#
#
t2 = p.vtest(t)
if t.var_namet !=  t2.var_namet:
  raise RuntimeError, "bad SWIGTYPE* typemap"
  

if cvar.fixsize != 'ho\0la\0\0\0':
  raise RuntimeError, "bad FIXSIZE typemap"

cvar.fixsize = 'ho'
if cvar.fixsize != 'ho\0\0\0\0\0\0':
  raise RuntimeError, "bad FIXSIZE typemap"


f = Foo(3)
f1 = fptr_val(f)
f2 = fptr_ref(f)
if f1._a != f2._a:
  raise RuntimeError, "bad const ptr& typemap"
  

v = char_foo(1,3)
if v !=3:
  raise RuntimeError, "bad int typemap"

s = char_foo(1,"hello")
if s !="hello":
  raise RuntimeError, "bad char* typemap"
  

v = SetPos(1,3)
if v !=4:
  raise RuntimeError, "bad int typemap"

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
cvar.var_pint = sct_pint
cvar.var_sizet = sct_sizet
cvar.var_hello = sct_hello
cvar.var_myint = sct_myint
cvar.var_namet = def_namet

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
p.var_pint = sct_pint
p.var_sizet = sct_sizet
p.var_hello = sct_hello
p.var_myint = sct_myint
p.var_namet = def_namet

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
t.var_pint = sct_pint
t.var_sizet = sct_sizet
t.var_hello = sct_hello
t.var_myint = sct_myint
t.var_namet = def_namet

t.v_check()

# this value contains a '0' char!
if def_namet != 'ho\0la':
  print "bad namet", def_namet
  raise RuntimeError

t.var_namet = def_namet
if t.var_namet != def_namet:
  print "bad namet", t.var_namet
  raise RuntimeError

t.var_namet = 'holac'

if t.var_namet != 'holac':
  print "bad namet", t.var_namet
  raise RuntimeError

t.var_namet = 'hol'

if t.var_namet != 'hol':
  print "bad namet", t.var_namet
  raise RuntimeError

largs=['hi','hola','hello']
if t.mainc(largs) != 3:
  raise RuntimeError, "bad main typemap"

targs=('hi','hola')
if t.mainv(targs,1) != 'hola':
  raise RuntimeError, "bad main typemap"


if t.strlen('hile') != 4:
  raise RuntimeError, "bad string typemap"

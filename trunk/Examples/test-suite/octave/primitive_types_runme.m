primitive_types

var_init();

# assigning globals calls
cvar.var_bool = sct_bool;
cvar.var_schar = sct_schar;
cvar.var_uchar = sct_uchar;
cvar.var_int = sct_int;
cvar.var_uint = sct_uint;
cvar.var_short = sct_short;
cvar.var_ushort = sct_ushort;
cvar.var_long = sct_long;
cvar.var_ulong = sct_ulong;
cvar.var_llong = sct_llong;
cvar.var_ullong = sct_ullong;
cvar.var_char = sct_char;
cvar.var_pchar = sct_pchar;
cvar.var_pcharc = sct_pcharc;
cvar.var_pint = sct_pint;
cvar.var_sizet = sct_sizet;
cvar.var_hello = sct_hello;
cvar.var_myint = sct_myint;
cvar.var_namet = def_namet;
cvar.var_parami = sct_parami;
cvar.var_paramd = sct_paramd;
cvar.var_paramc = sct_paramc;

v_check();

function octerror(name, val, cte)
  name, val, cte
  error
endfunction

if cvar.var_bool != cct_bool:
octerror("bool", cvar.var_bool, cct_bool)
endif
if cvar.var_schar != cct_schar:
octerror("schar", cvar.var_schar, cct_schar)
endif
if cvar.var_uchar != cct_uchar:
 octerror("uchar", cvar.var_uchar, cct_uchar)
endif
if cvar.var_int != cct_int:
 octerror("int", cvar.var_int, cct_int)
endif
if cvar.var_uint != cct_uint:
 octerror("uint", cvar.var_uint, cct_uint)
endif
if cvar.var_short != cct_short:
 octerror("short", cvar.var_short, cct_short)
endif
if cvar.var_ushort != cct_ushort:
 octerror("ushort", cvar.var_ushort, cct_ushort)
endif
if cvar.var_long != cct_long:
 octerror("long", cvar.var_long, cct_long)
endif
if cvar.var_ulong != cct_ulong:
 octerror("ulong", cvar.var_ulong, cct_ulong)
endif
if cvar.var_llong != cct_llong:
 octerror("llong", cvar.var_llong, cct_llong)
endif
if cvar.var_ullong != cct_ullong:
 octerror("ullong", cvar.var_ullong, cct_ullong)
endif
if cvar.var_char != cct_char:
 octerror("char", cvar.var_char, cct_char)
endif
if cvar.var_pchar != cct_pchar:
 octerror("pchar", cvar.var_pchar, cct_pchar)
endif
if cvar.var_pcharc != cct_pcharc:
 octerror("pchar", cvar.var_pcharc, cct_pcharc)
endif
if cvar.var_pint != cct_pint:
 octerror("pint", cvar.var_pint, cct_pint)
endif
if cvar.var_sizet != cct_sizet:
 octerror("sizet", cvar.var_sizet, cct_sizet)
endif
if cvar.var_hello != cct_hello:
 octerror("hello", cvar.var_hello, cct_hello)
endif
if cvar.var_myint != cct_myint:
 octerror("myint", cvar.var_myint, cct_myint)
endif
if cvar.var_namet != def_namet:
 octerror("name", cvar.var_namet, def_namet)
endif


function OctTest()
  self=subclass(TestDirector);
  self.ident=@(self,x) x;
  
  self.vval_bool=@(self, x) self.ident(x);
  self.vval_schar=@(self, x) self.ident(x);
  self.vval_uchar=@(self, x) self.ident(x);
  self.vval_int=@(self, x) self.ident(x);
  self.vval_uint=@(self, x) self.ident(x);
  self.vval_short=@(self, x) self.ident(x);
  self.vval_ushort=@(self, x) self.ident(x);
  self.vval_long=@(self, x) self.ident(x);
  self.vval_ulong=@(self, x) self.ident(x);
  self.vval_llong=@(self, x) self.ident(x);
  self.vval_ullong=@(self, x) self.ident(x);
  self.vval_float=@(self, x) self.ident(x);
  self.vval_double=@(self, x) self.ident(x);
  self.vval_char=@(self, x) self.ident(x);
  self.vval_pchar=@(self, x) self.ident(x);
  self.vval_pcharc=@(self, x) self.ident(x);
  self.vval_pint=@(self, x) self.ident(x);
  self.vval_sizet=@(self, x) self.ident(x);
  self.vval_hello=@(self, x) self.ident(x);
  self.vval_myint=@(self, x) self.ident(x);

  self.vref_bool=@(self, x) self.ident(x);
  self.vref_schar=@(self, x) self.ident(x);
  self.vref_uchar=@(self, x) self.ident(x);
  self.vref_int=@(self, x) self.ident(x);
  self.vref_uint=@(self, x) self.ident(x);
  self.vref_short=@(self, x) self.ident(x);
  self.vref_ushort=@(self, x) self.ident(x);
  self.vref_long=@(self, x) self.ident(x);
  self.vref_ulong=@(self, x) self.ident(x);
  self.vref_llong=@(self, x) self.ident(x);
  self.vref_ullong=@(self, x) self.ident(x);
  self.vref_float=@(self, x) self.ident(x);
  self.vref_double=@(self, x) self.ident(x);
  self.vref_char=@(self, x) self.ident(x);
  self.vref_pchar=@(self, x) self.ident(x);
  self.vref_pcharc=@(self, x) self.ident(x);
  self.vref_pint=@(self, x) self.ident(x);
  self.vref_sizet=@(self, x) self.ident(x);
  self.vref_hello=@(self, x) self.ident(x);
  self.vref_myint=@(self, x) self.ident(x);
endfunction


t = Test();
p = OctTest();


# internal call check
if (t.c_check() != p.c_check())
  error, "bad director"
endif

p.var_bool = p.stc_bool;
p.var_schar = p.stc_schar;
p.var_uchar = p.stc_uchar;
p.var_int = p.stc_int;
p.var_uint = p.stc_uint;
p.var_short = p.stc_short;
p.var_ushort = p.stc_ushort;
p.var_long = p.stc_long;
p.var_ulong = p.stc_ulong;
p.var_llong = p.stc_llong;
p.var_ullong = p.stc_ullong;
p.var_char = p.stc_char;
p.var_pchar = sct_pchar;
p.var_pcharc = sct_pcharc;
p.var_pint = sct_pint;
p.var_sizet = sct_sizet;
p.var_hello = sct_hello;
p.var_myint = sct_myint;
p.var_namet = def_namet;
p.var_parami = sct_parami;
p.var_paramd = sct_paramd;
p.var_paramc = sct_paramc;

p.v_check();

t.var_bool = t.stc_bool;
t.var_schar = t.stc_schar;
t.var_uchar = t.stc_uchar;
t.var_int = t.stc_int;
t.var_uint = t.stc_uint;
t.var_short = t.stc_short;
t.var_ushort = t.stc_ushort;
t.var_long = t.stc_long;
t.var_ulong = t.stc_ulong;
t.var_llong = t.stc_llong;
t.var_ullong = t.stc_ullong;
t.var_char = t.stc_char;
t.var_pchar = sct_pchar;
t.var_pcharc = sct_pcharc;
t.var_pint = sct_pint;
t.var_sizet = sct_sizet;
t.var_hello = sct_hello;
t.var_myint = sct_myint;
t.var_namet = def_namet;
t.var_parami = sct_parami;
t.var_paramd = sct_paramd;
t.var_paramc = sct_paramc;

t.v_check();

# this value contains a '0' char!
if (def_namet != 'ho\0la')
  error
endif

t.var_namet = def_namet;
if (t.var_namet != def_namet)
  error
endif

t.var_namet = 'holac';

if (t.var_namet != 'holac')
  error
endif

t.var_namet = 'hol';

if (t.var_namet != 'hol')
  error
endif

if (t.strlen('hile') != 4)
  error
endif

if (t.strlen('hil\0') != 4)
  error
endif

cvar.var_char = '\0';
if (cvar.var_char != '\0')
  error
endif
  
cvar.var_char = 0;
if (cvar.var_char != '\0')
  error
endif

cvar.var_namet = '\0';
if (cvar.var_namet != '')
  error
endif

cvar.var_namet = '';
if (cvar.var_namet != '')
  error, "bad char empty case"
endif

cvar.var_pchar = None;
if (cvar.var_pchar != None)
  error, "bad None case"
endif

cvar.var_pchar = '';
if (cvar.var_pchar != '')
  error
endif

cvar.var_pcharc = None;
if (cvar.var_pcharc != None)
  error
endif

cvar.var_pcharc = '';
if (cvar.var_pcharc != '')
  error
endif

#
# creating a raw char*
#
pc = new_pchar(5);
pchar_setitem(pc, 0, 'h');
pchar_setitem(pc, 1, 'o');
pchar_setitem(pc, 2, 'l');
pchar_setitem(pc, 3, 'a');
pchar_setitem(pc, 4, 0);


if (t.strlen(pc) != 4)
  error
endif

cvar.var_pchar = pc;
if (cvar.var_pchar != "hola")
  error
endif

cvar.var_namet = pc;
if (cvar.var_namet != "hola")
  error
endif

delete_pchar(pc);

#
# Now when things should fail
#

try
  error = 0;
  a = t.var_uchar;
  t.var_uchar = 10000;
  err = 1;
catch
  if (a != t.var_uchar)
    err = 1;
  endif
end_try_catch

if (err)
  error
endif

try
  err = 0;
  a = t.var_char;
  t.var_char = '23';
  err = 1;
catch
  if (a != t.var_char)
    error = 1
  endif
end_try_catch
if (err)
  error
endif

try
  err = 0
  a = t.var_uint
  t.var_uint = -1
  err = 1;
catch
  if a != t.var_uint:
    err = 1;
  endif
end_try_catch
if (err)
  error
endif

#
#
try
  err = 0;
  a = t.var_namet;
  t.var_namet = '123456';
  err = 1;
catch
  if (a != t.var_namet)
    err = 1;
  endif
end_try_catch
if (err)
  error
endif

#
#
#
t2 = p.vtest(t);
if (t.var_namet !=  t2.var_namet)
  error
endif
  

if (cvar.fixsize != 'ho\0la\0\0\0')
  error
endif

cvar.fixsize = 'ho';
if (cvar.fixsize != 'ho\0\0\0\0\0\0')
  error
endif


f = Foo(3);
f1 = fptr_val(f);
f2 = fptr_ref(f);
if (f1._a != f2._a)
  error
endif

v = char_foo(1,3);
if (v !=3)
  error
endif

s = char_foo(1,"hello");
if (s !="hello")
  error
endif
  

v = SetPos(1,3);
if (v !=4)
  error
endif

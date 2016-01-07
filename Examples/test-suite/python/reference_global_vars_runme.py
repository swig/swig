from reference_global_vars import *

# const class reference variable
if getconstTC().num != 33:
    raise RuntimeError

# primitive reference variables
cvar.var_bool = createref_bool(False)
if value_bool(cvar.var_bool) != False:
    raise RuntimeError

cvar.var_bool = createref_bool(True)
if value_bool(cvar.var_bool) != True:
    raise RuntimeError

cvar.var_char = createref_char('w')
if value_char(cvar.var_char) != 'w':
    raise RuntimeError

cvar.var_unsigned_char = createref_unsigned_char(10)
if value_unsigned_char(cvar.var_unsigned_char) != 10:
    raise RuntimeError

cvar.var_signed_char = createref_signed_char(10)
if value_signed_char(cvar.var_signed_char) != 10:
    raise RuntimeError

cvar.var_short = createref_short(10)
if value_short(cvar.var_short) != 10:
    raise RuntimeError

cvar.var_unsigned_short = createref_unsigned_short(10)
if value_unsigned_short(cvar.var_unsigned_short) != 10:
    raise RuntimeError

cvar.var_int = createref_int(10)
if value_int(cvar.var_int) != 10:
    raise RuntimeError

cvar.var_unsigned_int = createref_unsigned_int(10)
if value_unsigned_int(cvar.var_unsigned_int) != 10:
    raise RuntimeError

cvar.var_long = createref_long(10)
if value_long(cvar.var_long) != 10:
    raise RuntimeError

cvar.var_unsigned_long = createref_unsigned_long(10)
if value_unsigned_long(cvar.var_unsigned_long) != 10:
    raise RuntimeError

cvar.var_long_long = createref_long_long(0x6FFFFFFFFFFFFFF8)
if value_long_long(cvar.var_long_long) != 0x6FFFFFFFFFFFFFF8:
    raise RuntimeError

#ull = abs(0xFFFFFFF2FFFFFFF0)
ull = 55834574864
cvar.var_unsigned_long_long = createref_unsigned_long_long(ull)
if value_unsigned_long_long(cvar.var_unsigned_long_long) != ull:
    raise RuntimeError

cvar.var_float = createref_float(10.5)
if value_float(cvar.var_float) != 10.5:
    raise RuntimeError

cvar.var_double = createref_double(10.5)
if value_double(cvar.var_double) != 10.5:
    raise RuntimeError

# class reference variable
cvar.var_TestClass = createref_TestClass(TestClass(20))
if value_TestClass(cvar.var_TestClass).num != 20:
    raise RuntimeError

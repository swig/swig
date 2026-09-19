import python_typemap_ref_array as t
from swig_test_utils import swig_check

# A pointer or reference to a typedef'd array keeps its declared $1_type and $1_ltype, with $1_dim0 and $1_basetype from the array.
swig_check(t.cvar.const_sevens_ref, ("ConstSeven &", "ConstSeven *", "long", 7))
swig_check(t.cvar.const_sevens_ptr, ("ConstSeven *", "ConstSeven *", "long", 7))

# The [ANY] typemaps are matched behind the reference, with the dimension of the array referred to.
if t.cvar.numbers_ref != 4:
    raise RuntimeError("numbers_ref dimension %s" % t.cvar.numbers_ref)
if t.cvar.wide_ref != 7:
    raise RuntimeError("wide_ref dimension %s" % t.cvar.wide_ref)
if t.first_of(None) != 42:
    raise RuntimeError("first_of %s" % t.first_of(None))

# The same, for a typemap whose pattern is followed by a locals list.
if t.first_double(None) != 3:
    raise RuntimeError("first_double %s" % t.first_double(None))

# A pointer to an array carries its dimensions in the same way.
if t.first_short(None) != 5:
    raise RuntimeError("first_short %s" % t.first_short(None))
if t.cvar.shorts_ptr != 9:
    raise RuntimeError("shorts_ptr dimension %s" % t.cvar.shorts_ptr)

# A typemap for a reference to a function does not apply to a plain int.
if t.doubled(21) != 42:
    raise RuntimeError("doubled %s" % t.doubled(21))

# The library typemap for a reference to an array of char converts a string into the array.
if t.length_of("hello") != 5:
    raise RuntimeError("length_of %s" % t.length_of("hello"))

# $1_basetype leaves out every cv-qualifier of the element type, here one from each typedef.
swig_check(t.cvar.const_volatile_sevens_ref, ("ConstVolatileSeven &", "ConstVolatileSeven *", "long", 7))

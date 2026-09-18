import python_typemap_ref_array as t
from swig_test_utils import swig_check

# A reference to a typedef'd array keeps its declared $1_type and $1_ltype, with $1_dim0 and $1_basetype from the array.
swig_check(t.cvar.const_sevens_ref, ("ConstSeven &", "ConstSeven *", "long", 7))

# The [ANY] typemaps are matched behind the reference, with the dimension of the array referred to.
if t.cvar.numbers_ref != 4:
    raise RuntimeError("numbers_ref dimension %s" % t.cvar.numbers_ref)
if t.cvar.wide_ref != 7:
    raise RuntimeError("wide_ref dimension %s" % t.cvar.wide_ref)
if t.first_of(None) != 42:
    raise RuntimeError("first_of %s" % t.first_of(None))

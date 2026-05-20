import typemap_variables
from swig_test_utils import swig_check

# Issue #2056: qualified in typemaps must match member setters.
a = typemap_variables.StructA()
b = typemap_variables.StructB()

a.member = 42
swig_check(a.member, 11)
b.member = 99
swig_check(b.member, 22)

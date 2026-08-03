from constructor_rename import *
from swig_test_utils import swig_check

x = RenamedConstructor()
swig_check(x.answer(), 42)

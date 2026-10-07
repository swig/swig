from constructor_rename import *
from swig_test_utils import swig_check, swig_check_stub_declares

x = RenamedConstructor()
swig_check(x.answer(), 42)

# A renamed constructor is wrapped as a module scope function, so the stub has to declare it as one
swig_check_stub_declares("constructor_rename", "RenamedConstructor")

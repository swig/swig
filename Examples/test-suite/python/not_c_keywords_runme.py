from not_c_keywords import *
from swig_test_utils import swig_check

cs = ComplexStruct()
cs.init()
if cs.complex != 123:
    raise RuntimeError("complex not correct")
cs.complex = 456

swig_check(this_function(1), 2)

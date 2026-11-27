import sys

from li_std_vector_back_reference import *
from swig_test_utils import swig_check

def first_element():
    v = VectorWheel((Wheel(11), Wheel(22)))
    # v will be deleted after exit from this method
    return v[0]

size = first_element().size
if size != 11:
    raise RuntimeError("Back reference not working {}".format(size))

# An element returned from a container holds no more references to its 'this' than a new object
w = first_element()
w_new = Wheel(33)
swig_check(sys.getrefcount(w.this), sys.getrefcount(w_new.this))

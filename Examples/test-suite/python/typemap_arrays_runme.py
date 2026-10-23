from typemap_arrays import *
from swig_test_utils import swig_check

if sumA(None) != 60:
    raise RuntimeError("Sum is wrong")

swig_check(gridSize(None), 12)
swig_check(rowSize(None), 6)

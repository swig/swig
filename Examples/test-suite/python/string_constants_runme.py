import string_constants
from swig_test_utils import swig_check

swig_check(string_constants.things().embedded_nul_default(), True)

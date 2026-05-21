import char_enum_value
from swig_test_utils import swig_check, swig_assert

swig_check(char_enum_value.RED, 0)
swig_check(char_enum_value.BLUE, 1)
swig_check(char_enum_value.GREEN, 103)
swig_check(char_enum_value.NEWLINE, 10)
swig_check(char_enum_value.TAB, 9)
swig_check(char_enum_value.CAP_A, 65)
swig_assert(isinstance(char_enum_value.GREEN, int))

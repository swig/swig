import python_customdoc_c
from swig_test_utils import swig_assert, swig_check

swig_check(python_customdoc_c.add(2, 3), 5)
swig_assert("add(int left, int right) -> int" in python_customdoc_c.add.__doc__)
try:
    python_customdoc_c.add(object(), 3)
except TypeError as error:
    swig_assert("Prototype: add(int, int) -> int" in str(error))
else:
    raise RuntimeError("Expected TypeError")


def describe_arguments(*args):
    return tuple(type(arg).__name__ for arg in args)
python_customdoc_c.describe_arguments = describe_arguments
try:
    python_customdoc_c.add(object(), 3)
except TypeError as error:
    swig_assert("You have: ('object', 'int')" in str(error))
else:
    raise RuntimeError("Expected TypeError")

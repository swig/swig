from python_various import *
import datetime
import sys

class MyClass:
    pass

# Only implemented for python 3
if sys.version_info[0:2] < (3, 0):
    exit(0)

type = GetFullyQualifiedName(1234)  # Test builtins type
if type != "int":
    raise RuntimeError("wrong type {}".format(type))

type = GetFullyQualifiedName(MyClass())  # Test __main__ type
if type != "MyClass":
    raise RuntimeError("wrong type {}".format(type))

type = GetFullyQualifiedName(WrappedClass())  # Test a SWIG wrapped class
if type != "python_various.WrappedClass":
    raise RuntimeError("wrong type {}".format(type))

type = GetFullyQualifiedName(datetime.date(2020, 1, 20))  # Test a Python standard library class
if type != "datetime.date":
    raise RuntimeError("wrong type {}".format(type))

# Test return NULL for PyObject *
# Was resulting in: SystemError: <built-in function pyobject_test> returned a result with an exception set
try:
    pyobject_test(-5)
    raise RuntimeError("missing ArithmeticError")
except ArithmeticError as e:
    pass

pyobject_test(5)

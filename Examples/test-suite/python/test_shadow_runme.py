import test_shadow
from swig_test_utils import swig_assert
import inspect

r = test_shadow.global_func(3, 4)
swig_assert(r == 7)

r = test_shadow.shadowed_func(5, 6)
swig_assert(r == 30)

r = test_shadow.plain_func(10, 3)
swig_assert(r == 7)

# inspect.getsource does not work with -builtin
if not test_shadow.is_python_builtin():
    src = inspect.getsource(test_shadow.global_func)
    swig_assert("SHADOW WORKS" in src)
    src = inspect.getsource(test_shadow.shadowed_func)
    swig_assert("SHADOW WORKS" in src)
    src = inspect.getsource(test_shadow.plain_func)
    swig_assert("SHADOW WORKS" not in src)

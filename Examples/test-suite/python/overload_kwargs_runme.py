from overload_kwargs import MyStruct
from swig_test_utils import *

# Constructor with zero args (no kwargs)
s = MyStruct()
swig_assert(s.getA() == 0.0 and s.getB() == 0.0)

# Constructor with kwargs (2-overload case: zero-arg + two-arg)
s = MyStruct(a=3.0, b=4.0)
swig_assert(s.getA() == 3.0 and s.getB() == 4.0)

# Constructor with positional args still works
s = MyStruct(5.0, 6.0)
swig_assert(s.getA() == 5.0 and s.getB() == 6.0)

# Method with kwargs (2-overload case: zero-arg + two-arg)
swig_assert(s.foo(x=10.0, y=20.0) == 30.0)

# Method with no args
swig_assert(s.foo() == 0.0)

# Method with positional args still works
swig_assert(s.foo(1.0, 2.0) == 3.0)

# Unknown kwargs should raise TypeError
with swig_assert_raises(TypeError):
    MyStruct(nonexistent=10)

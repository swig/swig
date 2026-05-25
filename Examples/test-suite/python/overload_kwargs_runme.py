from overload_kwargs import MyStruct, gfoo
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

# Same-arity overloads distinguished by keyword name
swig_assert(s.bar(aa=3) == 3)
swig_assert(s.bar(bb="hi") == "hi")

# Three overloads selected by keyword subset
swig_assert(s.baz() == 0)
swig_assert(s.baz(x=5) == 5)
swig_assert(s.baz(x=1, y=2) == 3)

# Static method overloads with kwargs
swig_assert(MyStruct.sfoo(x=3.0) == 6.0)
swig_assert(MyStruct.sfoo(x=3.0, y=4.0) == 12.0)

# Global function overloads with kwargs
swig_assert(gfoo() == 0.0)
swig_assert(gfoo(x=1.0, y=2.0) == 3.0)

# Same keyword name, different types: first convertible overload wins
swig_assert(s.dup(v=3) == 3)
swig_assert(s.dup(v="seven") == "seven")
swig_assert(s.typed(value=21) == 42)
swig_assert(s.typed(value="hello") == 5)

# Defaulted parameters filled through kwargs only, including a skipped middle one
swig_assert(s.midDefault() == -1)
swig_assert(s.midDefault(x=1) == 301)
swig_assert(s.midDefault(x=1, z=2) == 103)

# Matching overloads keep working positionally
swig_assert(s.risky(5) == 5)
swig_assert(s.risky(1, 2) == 3)

# A genuine TypeError raised while executing a matched overload must propagate with its own message
try:
    s.risky(v=-5)
    swig_assert(False, "expected TypeError for negative value")
except TypeError as e:
    swig_assert("negative value" in str(e), "genuine TypeError was masked: {}".format(e))

# Unknown kwargs should raise TypeError
with swig_assert_raises(TypeError):
    MyStruct(nonexistent=10)

with swig_assert_raises(TypeError):
    s.foo(nonexistent=1.0)

with swig_assert_raises(TypeError):
    gfoo(nonexistent=1.0)

from cpp11_shared_ptr_container import StringVector
from swig_test_utils import swig_check

v = StringVector()

v.append("hello")
v.append("world")

swig_check(v[0], "hello")
swig_check(v[1], "world")

v[0] = "foo"
swig_check(v[0], "foo")

v[1] = "bar"
swig_check(v[1], "bar")

v.append("baz")
swig_check(v[2], "baz")

x = v.pop()
swig_check(x, "baz")

swig_check(len(v), 2)

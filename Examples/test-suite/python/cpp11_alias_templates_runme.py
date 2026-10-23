from cpp11_alias_templates import *

from swig_test_utils import swig_check


# Box<int> and Boxed<int> resolve to Container<int> = ContainerInt.
b = make_box(55)
swig_check(b.get(), 55)
b.set(77)
swig_check(b.get(), 77)

bb = make_boxed(99)
swig_check(bb.get(), 99)

# Quad<float> resolves to FixedArray<float, 4> = FixedArrayFloat4.
q = make_quad()
swig_check(q.size(), 4)
q.set(2, 3.5)
swig_check(q.get(2), 3.5)

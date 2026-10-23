from cpp11_this_member_initializer import *
from swig_test_utils import swig_check, swig_assert

n = Node()
swig_check(n.value, 1)
swig_check(n.deref(), 1)
swig_assert(n.is_self_parent(), "parent should be initialised to this")

n.value = 5
swig_check(n.deref(), 5)

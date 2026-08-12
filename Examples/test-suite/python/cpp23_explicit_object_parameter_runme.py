from cpp23_explicit_object_parameter import *
import cpp23_explicit_object_parameter as _mod

from swig_test_utils import swig_assert, swig_assert_raises, swig_check

c = Counter()
swig_check(c.value, 10)

# The explicit object parameter is the object itself, so each of these takes no arguments.
swig_check(c.by_lvalue_ref(), 11)
swig_check(c.by_const_ref(), 12)
swig_check(c.by_value(), 13)
swig_check(c.deduced(), 14)
swig_check(c.deduced_trailing(), 15)
swig_check(c.declared_only(), 17)

# Only the parameters declared after the explicit object parameter are wrapped.
swig_check(c.add(1, 2), 13)

# Passing the object explicitly is an error - it is not one of the method's arguments.
with swig_assert_raises(TypeError):
    c.by_lvalue_ref(c)
with swig_assert_raises(TypeError):
    c.add(1, 2, 3)

# Ordinary and static member functions declared alongside are unaffected.
swig_check(c.implicit_object(), 18)
swig_check(Counter.no_object(), 9)

chain = Chain()
swig_check(chain.self_ptr().value, 20)

# A lambda with an explicit object parameter parses but is not wrapped.
swig_assert(not hasattr(_mod, "recurse"), "recurse should not be wrapped")

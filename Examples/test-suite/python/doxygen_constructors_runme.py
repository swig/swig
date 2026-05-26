import doxygen_constructors
import inspect
import sys
import comment_verifier
from swig_test_utils import swig_check, swig_assert_raises


def check_ab(obj, a, b):
    """Assert the constructor stored a and b correctly on the C++ instance."""
    swig_check(obj.get_a(), a)
    swig_check(obj.get_b(), b)


# Constructor docstrings reach __init__ in both -builtin and non-builtin.
comment_verifier.check(inspect.getdoc(doxygen_constructors.ClassZeroArg.__init__), "Zero arg ctor doc.")
comment_verifier.check(inspect.getdoc(doxygen_constructors.ClassOneArg.__init__), "One arg ctor doc.")
comment_verifier.check(inspect.getdoc(doxygen_constructors.ClassTwoArg.__init__), "Two arg ctor doc.")
comment_verifier.check(inspect.getdoc(doxygen_constructors.ClassKwArg.__init__), "Kwarg ctor doc.")

# Positional construction; argument values reach the C++ members.
doxygen_constructors.ClassZeroArg()
swig_check(doxygen_constructors.ClassOneArg(11).get_a(), 11)
check_ab(doxygen_constructors.ClassTwoArg(11, 2.5), 11, 2.5)
check_ab(doxygen_constructors.ClassKwArg(11, 22), 11, 22)

# Wrong arg count raises TypeError, identical between wrapping modes.
with swig_assert_raises(TypeError):
    doxygen_constructors.ClassZeroArg(1)
with swig_assert_raises(TypeError):
    doxygen_constructors.ClassOneArg()
with swig_assert_raises(TypeError):
    doxygen_constructors.ClassOneArg(1, 2)
with swig_assert_raises(TypeError):
    doxygen_constructors.ClassTwoArg(1)
with swig_assert_raises(TypeError):
    doxygen_constructors.ClassTwoArg(1, 2.0, 3)

# Without %feature("kwargs"), kwarg handling diverges between wrapping modes (long standing SWIG
# behaviour, not specific to doxygen): the non-builtin shadow __init__ is a Python function and
# accepts kwargs natively, while the builtin tp_init C wrapper only accepts positional args. The
# %feature("kwargs") path below is where the two modes are expected to behave identically.

# With %feature("kwargs"), kwarg order does not affect which value binds to which name,
# and mixed positional/kwarg works.
check_ab(doxygen_constructors.ClassKwArg(a=11, b=22), 11, 22)
check_ab(doxygen_constructors.ClassKwArg(b=22, a=11), 11, 22)  # reversed kwarg order
check_ab(doxygen_constructors.ClassKwArg(11, b=22), 11, 22)    # mixed positional + kwarg

# Unknown kwarg name and missing arg both raise TypeError, identical in both modes.
with swig_assert_raises(TypeError):
    doxygen_constructors.ClassKwArg(c=1, d=2)
with swig_assert_raises(TypeError):
    doxygen_constructors.ClassKwArg(a=1)

# Direct instantiation Cls(args) calls the tp_init slot and bypasses tp_dict["__init__"]
# altogether, so it does not exercise the descriptor SWIG installs under -builtin to carry
# the doxygen docstring. super().__init__() from a Python subclass is the realistic path
# that does an attribute lookup and lands on that descriptor. The subclasses below run
# that path for positional and keyword args.
# Python 2 still requires the explicit super(Cls, self) form; remove the legacy branch
# when Python 2 support is dropped.
if sys.version_info[0:2] < (3, 0):
    class TwoArgSubclass(doxygen_constructors.ClassTwoArg):
        def __init__(self, a, b, label):
            super(TwoArgSubclass, self).__init__(a, b)
            self.label = label

    class KwArgSubclass(doxygen_constructors.ClassKwArg):
        def __init__(self, **kw):
            super(KwArgSubclass, self).__init__(**kw)
else:
    class TwoArgSubclass(doxygen_constructors.ClassTwoArg):
        def __init__(self, a, b, label):
            super().__init__(a, b)
            self.label = label

    class KwArgSubclass(doxygen_constructors.ClassKwArg):
        def __init__(self, **kw):
            super().__init__(**kw)

sub = TwoArgSubclass(11, 2.5, "subclass-tag")
swig_check(sub.get_a(), 11)
swig_check(sub.get_b(), 2.5)
swig_check(sub.label, "subclass-tag")

check_ab(KwArgSubclass(a=11, b=22), 11, 22)
check_ab(KwArgSubclass(b=22, a=11), 11, 22)

# Confirm the descriptor SWIG installed actually replaced CPython's auto-installed slot
# wrapper. PyType_Ready's add_operators populates tp_dict["__init__"] with a
# wrapper_descriptor (type(object.__init__)) whose docstring is the fixed generic
# "Initialize self." string. PyDescr_NewMethod produces a method_descriptor
# (type(list.append)). Combined with the docstring checks above and the super().__init__()
# calls above, this proves the wrapper is the call path under -builtin and not the default
# slot wrapper.
# Note:
#   >>> type(list.append).__name__
#   'method_descriptor'
#   >>> type(object.__init__).__name__
#   'wrapper_descriptor'
if doxygen_constructors.is_python_builtin():
    swig_check(type(doxygen_constructors.ClassZeroArg.__init__).__name__, "method_descriptor")
    swig_check(type(doxygen_constructors.ClassTwoArg.__init__).__name__, "method_descriptor")
    swig_check(type(doxygen_constructors.ClassKwArg.__init__).__name__, "method_descriptor")

    # Control: ClassNoDoc has no doxygen comment on its constructor, so SWIG does not emit
    # the __init__ descriptor override and PyType_Ready's auto-installed slot wrapper stays
    # in place.  Its descriptor type matches type(object.__init__) and differs from the
    # documented classes above.
    swig_check(type(doxygen_constructors.ClassNoDoc.__init__).__name__, "wrapper_descriptor")
    swig_check(type(doxygen_constructors.ClassNoDoc.__init__), type(object.__init__))

    swig_check(type(doxygen_constructors.ClassKwArg.__init__), type(list.append))


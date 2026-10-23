from swig_test_utils import swig_assert, swig_check

from cpp11_python_abstractbase import *
import collections.abc

# This is expected to fail with -builtin option
# Builtin types can't inherit from pure-python abstract bases
if is_python_builtin():
    exit(0)

def check_issubclass(derived, base):
    swig_assert(issubclass(derived, base), "{} is not a subclass of {}".format(derived, base))

check_issubclass(UnorderedMapii, collections.abc.MutableMapping)
check_issubclass(UnorderedMultimapii, collections.abc.MutableMapping)
check_issubclass(UnorderedIntSet, collections.abc.MutableSet)
check_issubclass(UnorderedIntMultiset, collections.abc.MutableSet)

# MutableSet declares add and discard abstract, so a container without them cannot be instantiated
unorderedmapii = UnorderedMapii()
unorderedmultimapii = UnorderedMultimapii()
unorderedintset = UnorderedIntSet()
unorderedintmultiset = UnorderedIntMultiset()

unorderedintset.add(1)
unorderedintset.add(2)
swig_check(sorted(unorderedintset), [1, 2])

unorderedintset.discard(1)
swig_check(sorted(unorderedintset), [2])

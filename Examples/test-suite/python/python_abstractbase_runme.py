import sys

# collections.abc requires Python 3.3+
if sys.version_info[0:2] < (3, 3):
    exit(0)

from python_abstractbase import *
import collections.abc

# This is expected to fail with -builtin option
# Builtin types can't inherit from pure-python abstract bases
if is_python_builtin():
    exit(0)

# Python abc is only turned on when -py3 option is passed to SWIG
if not is_swig_py3:
    exit(0)

def check_issubclass(derived, base):
    if not issubclass(derived, base):
        raise RuntimeError("{} is not a subclass of {}".format(derived, base))

check_issubclass(Mapii, collections.abc.MutableMapping)
check_issubclass(Multimapii, collections.abc.MutableMapping)
check_issubclass(IntSet, collections.abc.MutableSet)
check_issubclass(IntMultiset, collections.abc.MutableSet)
check_issubclass(IntVector, collections.abc.MutableSequence)
check_issubclass(IntList, collections.abc.MutableSequence)

mapii = Mapii()
multimapii = Multimapii()
intset = IntSet()
intmultiset = IntMultiset()
intvector = IntVector()
intlist = IntList()

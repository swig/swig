from python_abstractbase import *
from collections import *

# This is expected to fail with -builtin option
# Builtin types can't inherit from pure-python abstract bases
if is_python_builtin():
    exit(0)

assert issubclass(Mapii, MutableMapping)
assert issubclass(Multimapii, MutableMapping)
assert issubclass(IntSet, MutableSet)
assert issubclass(IntMultiset, MutableSet)
assert issubclass(IntVector, MutableSequence)
assert issubclass(IntList, MutableSequence)

mapii = Mapii()
multimapii = Multimapii()
intset = IntSet()
intmultiset = IntMultiset()
intvector = IntVector()
intlist = IntList()

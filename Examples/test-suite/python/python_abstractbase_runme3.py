from python_abstractbase import *
from collections import *

# This is expected to fail with -builtin option
# Builtin types can't inherit from pure-python abstract bases

assert issubclass(Mapii, MutableMapping)
assert issubclass(Multimapii, MutableMapping)
assert issubclass(IntSet, MutableSet)
assert issubclass(IntMultiset, MutableSet)
assert issubclass(IntVector, MutableSequence)
assert issubclass(IntList, MutableSequence)

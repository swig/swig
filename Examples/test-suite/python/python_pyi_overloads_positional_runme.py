import re

from swig_test_utils import swig_check, swig_assert, swig_assert_raises
import python_pyi_overloads_positional

# The functions should work regardless of Python version.
swig_check(python_pyi_overloads_positional.overloaded(), 42)
swig_check(python_pyi_overloads_positional.overloaded(1), 2)
swig_check(python_pyi_overloads_positional.overloaded(1, 2), 3)
swig_check(python_pyi_overloads_positional.not_overloaded(1, 2), 3)

with open("python_pyi_overloads_positional.pyi") as f:
    lines = f.read().splitlines()

idx = lines.index('@typing.overload')
swig_assert(idx >= 0)
swig_check(lines[idx], "@typing.overload")
# Shouldn't have a '/' in the function.
swig_check(lines[idx + 1], 'def overloaded() -> "int":')

idx = lines.index('@typing.overload', idx+1)
swig_assert(idx >= 0)
swig_check(lines[idx], "@typing.overload")
swig_check(lines[idx + 1], 'def overloaded(a: "int", /) -> "int":')

idx = lines.index('@typing.overload', idx+1)
swig_assert(idx >= 0)
swig_check(lines[idx], "@typing.overload")
swig_check(lines[idx + 1], 'def overloaded(a: "int", b: "int", /) -> "int":')

# There shouldn't be a positional-only marker for non-overloaded functions.
idx = lines.index('def not_overloaded(a: "int", b: "int") -> "int":', idx+1)
swig_assert(idx >= 0)

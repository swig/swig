import python_pyi_untyped
from swig_test_utils import swig_assert, swig_check

swig_check(python_pyi_untyped.Base().value(), 1)
swig_check(python_pyi_untyped.cvar.global_variable, 3)

with open("python_pyi_untyped.pyi") as stub_file:
    stub = stub_file.read()

# Everything the module exports has to be declared whether or not there are annotations to declare
for declaration in ("def thisown", "def __disown__", "cvar", "def value"):
    swig_assert(declaration in stub, "{} is missing from the generated stub".format(declaration))

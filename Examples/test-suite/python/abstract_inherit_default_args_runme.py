from abstract_inherit_default_args import *
from swig_test_utils import swig_check

for c in [ConcreteDerived(), ConcreteDerivedDerived(), ConcreteDerivedDefault(), ConcreteAbstractDerived()]:
    swig_check(call_f(c, 1), 1)

try:
    AbstractDerived()
    raise RuntimeError("AbstractDerived should be abstract")
except (AttributeError, TypeError): # TypeError is thrown when using -builtin
    pass

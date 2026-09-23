from abstract_inherit_default_args import *

for c in [ConcreteDerived(), ConcreteDerivedDerived(), ConcreteDerivedDefault(), ConcreteAbstractDerived()]:
    if c.f(1, 2) != 3:
        raise RuntimeError("f(1, 2) failed for " + type(c).__name__)
    if AbstractBase.f(c, 1) != 1:
        raise RuntimeError("AbstractBase.f(1) failed for " + type(c).__name__)

if ConcreteDerivedDefault().f(1) != 1:
    raise RuntimeError("f(1) failed for ConcreteDerivedDefault")

try:
    AbstractDerived()
    raise RuntimeError("AbstractDerived should be abstract")
except (AttributeError, TypeError): # TypeError is thrown when using -builtin
    pass

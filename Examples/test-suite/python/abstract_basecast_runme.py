from abstract_basecast import *

def check(flag):
    if not flag:
        raise RuntimeError("Test failed")

derived = DerivedClass()
derived.g()
check(isinstance(derived, BaseClass))
check(isinstance(derived, DerivedClass))

base = derived.f()
base.g()
check(isinstance(base, BaseClass))
check(not isinstance(base, DerivedClass))

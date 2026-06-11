from cpp11_inheriting_constructors import *

# Constructor inheritance via using declaration
d = DerivedClass(10)
if d.retrieveValue() != 10:
    raise RuntimeError("retrieveValue() failed");

# A protected member brought into the public interface through a typedef naming a base that has inheriting constructors
if UseInheritCtorTypedef(42).protectedValue() != 42:
    raise RuntimeError("UseInheritCtorTypedef.protectedValue() failed");

# Member initialization at the site of the declaration
s = SomeClass()
if s.value != 5:
    raise RuntimeError("s.value failed");

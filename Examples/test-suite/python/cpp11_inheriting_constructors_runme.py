from cpp11_inheriting_constructors import *

# Constructor inheritance via using declaration
d = DerivedClass(10)
if d.retrieveValue() != 10:
    raise RuntimeError("retrieveValue() failed");

# Member initialization at the site of the declaration
s = SomeClass()
if s.value != 5:
    raise RuntimeError("s.value failed");

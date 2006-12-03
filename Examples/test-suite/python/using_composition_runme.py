from using_composition import *

f = FooBar()
if f.blah(3) != 3:
    raise RuntimeError,"blah(int)"

if f.blah(3.5) != 3.5:
    raise RuntimeError,"blah(double)"

if f.blah("hello") != "hello":
    raise RuntimeError,"blah(char *)"

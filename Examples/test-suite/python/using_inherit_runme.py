from using_inherit import *

b = Bar()
if b.test(3) != 3:
    raise RuntimeError,"test(int)"

if b.test(3.5) != 3.5:
    raise RuntimeError, "test(double)"

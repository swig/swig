from li_std_wstream import *


a = A()

o = wostringstream()

o << a << " " << 2345 << " " << 1.435 << wends

if o.str() != "A class 2345 1.435\0":
    raise RuntimeError("str failed: \"%s\"".format(o.str()))

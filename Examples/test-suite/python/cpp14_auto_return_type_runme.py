from cpp14_auto_return_type import *

sc = va_static_cast()
if sc != 42:
    raise RuntimeError("va_static_cast fail {}".format(sc))

x = X()
a = x.a()
if a != "a string":
    raise RuntimeError("x.a fail {}".format(a))

from swigobject import *
import sys

a = A()


a1 = a_ptr(a)
a2 = a_ptr(a)

if a1.this != a2.this:
    raise RuntimeError


if sys.version_info[0:2] < (3, 0):
    lthis = long(a.this)
else:
    lthis = int(a.this)

# match pointer value, but deal with leading zeros on 8/16 bit systems and
# different C++ compilers interpretation of %p
xstr1 = "%016X" % (lthis,)
xstr1 = str.lstrip(xstr1, "0")
xstr2 = pointer_str(a)
xstr2 = str.replace(xstr2, "0x", "")
xstr2 = str.replace(xstr2, "0X", "")
xstr2 = str.lstrip(xstr2, "0")
xstr2 = str.upper(xstr2)

if xstr1 != xstr2:
    raise RuntimeError("Not equal failed {} {}".format(xstr1, xstr2))

s = str(a.this)
r = repr(a.this)

v1 = v_ptr(a)
v2 = v_ptr(a)

if sys.version_info[0:2] < (3, 0):
    if long(v1) != long(v2):
        raise RuntimeError
else:
    if int(v1) != int(v2):
        raise RuntimeError

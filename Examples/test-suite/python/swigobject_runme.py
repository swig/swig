
from swigobject import  *
from string import replace
from string import upper
from string import lstrip

a = A()


a1 = a_ptr(a)
a2 = a_ptr(a)

if a1.this != a2.this:
  raise RuntimeError
  

lthis = long(a.this)
# match pointer value, but deal with leading zeros on 8/16 bit systems and different C++ compilers interpretation of %p
xstr1 = "%016X" % (lthis,)
xstr1 = lstrip(xstr1, '0')
xstr2 = pointer_str(a)
xstr2 = replace(xstr2, "0x", "")
xstr2 = replace(xstr2, "0X", "")
xstr2 = upper(xstr2)

if xstr1 != xstr2:
  print xstr1, xstr2
  raise RuntimeError

s = str(a.this)
r = repr(a.this)

v1 = v_ptr(a)
v2 = v_ptr(a)
if long(v1) != long(v2):
  raise RuntimeError

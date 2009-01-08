
from swigobject import  *

a = A()


a1 = a_ptr(a)
a2 = a_ptr(a)

if a1.this != a2.this:
  raise RuntimeError
  

lthis = long(a.this)
# match pointer value, but deal with leading zeros on 8/16 bit systems
xstr8bit  = "%08X" % (lthis,)
xstr16bit = "%016X" % (lthis,)
xstr2 = pointer_str(a)

if xstr8bit != xstr2:
  if xstr16bit != xstr2:
    print  xstr8bit, xstr16bit, xstr2
    raise RuntimeError

s = str(a.this)
r = repr(a.this)

v1 = v_ptr(a)
v2 = v_ptr(a)
if long(v1) != long(v2):
  raise RuntimeError

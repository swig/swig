from swigobject import  *

a = A()


a1 = a_ptr(a)
a2 = a_ptr(a)

if a1.this != a2.this:
  raise RuntimeError
  

lthis = long(a.this)
xstr1 = "0x%x" % (lthis,)
xstr2 = pointer_str(a)

print hex(lthis)
if xstr1 != xstr2:
  print  xstr1, xstr2
  raise RuntimeError

s = str(a.this)
r = repr(a.this)

v1 = v_ptr(a)
v2 = v_ptr(a)
if long(v1) != long(v2):
  raise RuntimeError

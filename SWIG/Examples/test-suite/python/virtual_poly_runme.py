import virtual_poly

d = virtual_poly.NDouble(3.5)
i = virtual_poly.NInt(2)

#
# the copy methods return the right polymorphic types
# 
dc = d.copy()
ic = i.copy()

if d.get() != dc.get():
  raise RuntimeError

if i.get() != ic.get():
  raise RuntimeError


#
# here this dynamic_cast is not needed at all,
# but works fine anyway ('nnumber()' returns a NNumber).
#
ddc = virtual_poly.NDouble_dynamic_cast(dc.nnumber())
if d.get() != ddc.get():
  raise RuntimeError

dic = virtual_poly.NInt_dynamic_cast(ic.nnumber())
if i.get() != dic.get():
  raise RuntimeError

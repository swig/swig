import virtual_poly


d = virtual_poly.NDouble(3.5)
i = virtual_poly.NInt(2)

dc = d.copy()
ic = i.copy()

if d.get() != dc.get():
  raise RuntimeError

if i.get() != ic.get():
  raise RuntimeError


ddc = virtual_poly.NDouble_dynamic_cast(dc)
if d.get() != ddc.get():
  raise RuntimeError

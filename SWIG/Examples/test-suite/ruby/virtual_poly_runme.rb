require 'virtual_poly'

d = Virtual_poly::NDouble.new(3.5)
i = Virtual_poly::NInt.new(2)

#
# polymorphic return type working
#
dc = d.copy
ic = i.copy

raise RuntimeError if d.get != dc.get
raise RuntimeError if i.get != ic.get

#
# dynamic cast working ('nnumber' returns a NNumber)
#
ddc = Virtual_poly.NDouble_dynamic_cast(dc.nnumber)
raise RuntimeError if d.get != ddc.get 

dic = Virtual_poly.NInt_dynamic_cast(ic.nnumber)
raise RuntimeError if i.get != dic.get

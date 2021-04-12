virtual_poly

d = virtual_poly.NDouble(3.5);
i = virtual_poly.NInt(2);

#
# the copy methods return the right polymorphic types
# 
dc = d.copy();
ic = i.copy();

if (d.get() != dc.get())
  error("failed");
endif

if (i.get() != ic.get())
  error("failed");
endif

virtual_poly.incr(ic);

if ((i.get() + 1) != ic.get())
  error("failed");
endif


dr = d.ref_this();
if (d.get() != dr.get())
  error("failed");
endif


#
# 'narrowing' also works
#
ddc = virtual_poly.NDouble_narrow(d.nnumber());
if (d.get() != ddc.get())
  error("failed");
endif

dic = virtual_poly.NInt_narrow(i.nnumber());
if (i.get() != dic.get())
  error("failed");
endif

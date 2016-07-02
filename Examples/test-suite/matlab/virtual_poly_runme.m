d = virtual_poly.NDouble(3.5);
i = virtual_poly.NInt(2);

%
% the copy methods return the right polymorphic types
% 
dc = d.copy();
ic = i.copy();

if (d.get() ~= dc.get())
  error('Failed!')
end

if (i.get() ~= ic.get())
  error('Failed!')
end

virtual_poly.incr(ic);

if ((i.get() + 1) ~= ic.get())
  error('Failed!')
end


dr = d.ref_this();
if (d.get() ~= dr.get())
  error('Failed!')
end


%
% 'narrowing' also works
%
ddc = virtual_poly.NDouble.narrow(d.nnumber());
if (d.get() ~= ddc.get())
  error('Failed!')
end

dic = virtual_poly.NInt.narrow(i.nnumber());
if (i.get() ~= dic.get())
  error('Failed!')
end

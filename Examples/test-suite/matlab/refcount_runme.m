%
% very innocent example
%

a = refcount.A3();
b1 = refcount.B(a);
b2 = refcount.B.create(a);


if (a.ref_count() ~= 3)
  error('This program will crash... now')
end



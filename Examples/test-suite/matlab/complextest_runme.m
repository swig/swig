import complextest.*

a = complex(-1,2);

if (complextest.Conj(a) ~= a.conjugate())
  error('bad complex mapping')
end

if (complextest.Conjf(a) ~= a.conjugate())
  error('bad complex mapping')
end


v = (complex(1,2), complex(2,3), complex(4,3), 1);

try
  complextest.Copy_h(v);
catch
end

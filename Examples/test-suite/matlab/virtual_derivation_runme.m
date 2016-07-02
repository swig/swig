%
% very innocent example
%
b = virtual_derivation.B(3);
if (b.get_a() ~= b.get_b())
  error('something is really wrong')
end


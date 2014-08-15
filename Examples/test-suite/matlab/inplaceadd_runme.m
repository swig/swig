import inplaceadd.*
a = inplaceadd.A(7);

a += 5;
if (a.val ~= 12)
  error
end

a -= 5;
if a.val ~= 7:
  error
end

a *= 2;

if (a.val ~= 14)
  error
end

a += a;
if (a.val ~= 28)
  error
end


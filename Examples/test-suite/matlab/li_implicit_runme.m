import li_implicit.*
b = B();
ai = A(1);
ad = A(2.0);
ab = A(b);

ai, get(ai);
ad, get(ad);
ab, get(ab);

if (get(ai) ~= get(1))
  error('bad implicit type')
end
if (get(ad) ~= get(2.0))
  error('bad implicit type')
end
if (get(ab) ~= get(b))
  error('bad implicit type')
end


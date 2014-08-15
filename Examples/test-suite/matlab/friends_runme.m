import friends.*

a = friends.A(2);

if (friends.get_val1(a) ~= 2)
  error('Failed!!')
end
if (friends.get_val2(a) ~= 4)
  error('Failed!!')
end
if (friends.get_val3(a) ~= 6)
  error('Failed!!')
end

				% nice overload working fine
if (friends.get_val1(1,2,3) ~= 1)
  error('Failed!!')
end

b = friends.B(3);

				% David's case
if (friends.mix(a,b) ~= 5)
  error('Failed!!')
end

di = friends.D_d(2);
dd = friends.D_d(3.3);

				% incredible template overloading working just fine
if (friends.get_val1(di) ~= 2)
  error('Failed!!')
end
if (friends.get_val1(dd) ~= 3.3)
  error('Failed!!')
end

friends.set(di, 4);
friends.set(dd, 1.3);

if (friends.get_val1(di) ~= 4)
  error('Failed!!')
end
if (friends.get_val1(dd) ~= 1.3)
  error('Failed!!')
end

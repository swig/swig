b = using_inherit.Bar();
if (b.test(3) ~= 3)
  error('Bar::test(int)')
end

if (b.test(3.5) ~= 3.5)
  error('Bar::test(double)')
end


b = using_inherit.Bar2();
if (b.test(3) ~= 6)
  error('Bar2::test(int)')
end

if (b.test(3.5) ~= 7.0)
  error('Bar2::test(double)')
end


b = using_inherit.Bar3();
if (b.test(3) ~= 6)
  error('Bar3::test(int)')
end

if (b.test(3.5) ~= 7.0)
  error('Bar3::test(double)')
end


b = using_inherit.Bar4();
if (b.test(3) ~= 6)
  error('Bar4::test(int)')
end

if (b.test(3.5) ~= 7.0)
  error('Bar4::test(double)')
end


b = using_inherit.Fred1();
if (b.test(3) ~= 3)
  error('Fred1::test(int)')
end

if (b.test(3.5) ~= 7.0)
  error('Fred1::test(double)')
end


b = using_inherit.Fred2();
if (b.test(3) ~= 3)
  error('Fred2::test(int)')
end

if (b.test(3.5) ~= 7.0)
  error('Fred2::test(double)')
end


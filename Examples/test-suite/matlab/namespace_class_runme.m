import namespace_class.*

try
  p = Private1();
  ok = 1;
catch
  ok = 0;
end

if (ok)
  error('Private1 is private')
end

try
  p = Private2();
  ok = 1;
catch
  ok = 0;
end

if (ok)
  error('Private2 is private')
end

EulerT3D.toFrame(1,1,1);

b = BooT_i();
b = BooT_H();


f = FooT_i();
f.quack(1);

f = FooT_d();
f.moo(1);

f = FooT_H();
f.foo(Hi);


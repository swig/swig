try
  p = namespace_class.Private1();
  ok = 1;
catch
  ok = 0;
end

if (ok)
  error('Private1 is private')
end

try
  p = namespace_class.Private2();
  ok = 1;
catch
  ok = 0;
end

if (ok)
  error('Private2 is private')
end

namespace_class.EulerT3D.toFrame(1,1,1);

b = namespace_class.BooT_i();
b = namespace_class.BooT_H();


f = namespace_class.FooT_i();
f.quack(1);

f = namespace_class.FooT_d();
f.moo(1);

f = namespace_class.FooT_H();
f.foo(namespace_class.Hi);


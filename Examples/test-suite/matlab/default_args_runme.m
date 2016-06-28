if (default_args.Statics.staticmethod() ~= 60)
  error
end

if (default_args.cfunc1(1) ~= 2)
  error
end

if (default_args.cfunc2(1) ~= 3)
  error
end

if (default_args.cfunc3(1) ~= 4)
  error
end


f = default_args.Foo();

f.newname();
f.newname(1);


try
  f = default_args.Foo(1);
  ok = 1;
catch
  ok = 0;
end
if (ok)
  error('Foo::Foo ignore is not working')
end

try
  f = default_args.Foo(1,2);
  ok = 1;
catch
  ok = 0;
end
if (ok)
  error('Foo::Foo ignore is not working')
end

try
  f = default_args.Foo(1,2,3);
  ok = 1;
catch
  ok = 0;
end
if (ok)
  error('Foo::Foo ignore is not working')
end

try
  m = f.meth(1);
  ok = 1;
catch
  ok = 0;
end
if (ok)
  error('Foo::meth ignore is not working')
end

try
  m = f.meth(1,2);
  ok = 1;
catch
  ok = 0;
end
if (ok)
  error('Foo::meth ignore is not working')
end

try
  m = f.meth(1,2,3);
  ok = 1;
catch
  ok = 0;
end
if (ok)
  error('Foo::meth ignore is not working')
end

import voidtest.*

voidtest.globalfunc();
f = voidtest.Foo();
f.memberfunc();

voidtest.Foo.staticmemberfunc();

try
  a = f.memberfunc();
catch
end
try
  a = voidtest_helper();
catch
end


v1 = voidtest.vfunc1(f);
v2 = voidtest.vfunc2(f);
if (swig_this(v1) ~= swig_this(v2))
  error('Failed!!')
end

v3 = voidtest.vfunc3(v1);
if (swig_this(v3) ~= swig_this(f))
  error('Failed!!')
end
v4 = voidtest.vfunc1(f);
if (swig_this(v4) ~= swig_this(v1))
  error('Failed!!')
end


v3.memberfunc();

import smart_pointer_member.*

f = Foo();
f.y = 1;

if (f.y ~= 1)
  error
end

b = Bar(f);
b.y = 2;

if (f.y ~= 2)
  error('f.y = %i, b.y = %i',f.y,b.y)
end

% no swig_this yet
%if (swig_this(b.x) ~= swig_this(f.x))
%    error('swig+this Failed!!')
%end

if (b.z ~= f.z)
  error
end

try
  if (Foo.z == Bar.z)
    error
  end
    error
catch
end

  







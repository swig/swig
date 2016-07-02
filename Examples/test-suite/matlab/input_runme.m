f = input.Foo();
if (f.foo(2) ~= 4)
  error
end

try
  a=f.foo();
  error
catch
end

if (~strcmp(sfoo('Hello'),'Hello world'))
  error
end

try
  a=sfoo();
  error
catch
end

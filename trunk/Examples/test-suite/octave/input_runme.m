input

f = Foo();
if (f.foo(2) != 4)
  error
endif

try
  a=f.foo();
  error
catch
end_try_catch

if (!strcmp(sfoo("Hello"),"Hello world"))
  error
endif

try
  a=sfoo();
  error
catch
end_try_catch

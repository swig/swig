import kwargs

if kwargs.foo(a=1,b=2) != 3:
  raise RuntimeError

if kwargs.foo(b=2) != 3:
  raise RuntimeError

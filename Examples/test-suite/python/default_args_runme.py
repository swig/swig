import default_args 


if default_args.Statics_staticMethod() != 60:
  raise RuntimeError
  
if default_args.cfunc1(1) != 2:
  raise RuntimeError

if default_args.cfunc2(1) != 3:
  raise RuntimeError

if default_args.cfunc3(1) != 4:
  raise RuntimeError


f = default_args.Foo()

f.newname()
f.newname(1)


try:
  f = default_args.Foo(1)
  error = 1
except:
  error = 0
if error:  raise RuntimeError,"Foo::Foo ignore is not working"

try:
  f = default_args.Foo(1,2)
  error = 1
except:
  error = 0
if error:  raise RuntimeError,"Foo::Foo ignore is not working"

try:
  f = default_args.Foo(1,2,3)
  error = 1
except:
  error = 0
if error:  raise RuntimeError,"Foo::Foo ignore is not working"

try:
  m = f.meth(1)
  error = 1
except:
  error = 0
if error:  raise RuntimeError,"Foo::meth ignore is not working"

try:
  m = f.meth(1,2)
  error = 1
except:
  error = 0
if error:  raise RuntimeError,"Foo::meth ignore is not working"

try:
  m = f.meth(1,2,3)
  error = 1
except:
  error = 0
if error:  raise RuntimeError,"Foo::meth ignore is not working"


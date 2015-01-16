# Note that this test is also used by python_default_args_runme.py hence the use of __main__ and the run function

def run(module_name):
  default_args = __import__(module_name)
  ec = default_args.EnumClass()
  if not ec.blah():
    raise RuntimeError("EnumClass::blah() default arguments don't work")

  de = default_args.DerivedEnumClass()
  de.accelerate()
  de.accelerate(default_args.EnumClass.SLOW)

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
  if error:  raise RuntimeError("Foo::Foo ignore is not working")

  try:
    f = default_args.Foo(1,2)
    error = 1
  except:
    error = 0
  if error:  raise RuntimeError("Foo::Foo ignore is not working")

  try:
    f = default_args.Foo(1,2,3)
    error = 1
  except:
    error = 0
  if error:  raise RuntimeError("Foo::Foo ignore is not working")

  try:
    m = f.meth(1)
    error = 1
  except:
    error = 0
  if error:  raise RuntimeError("Foo::meth ignore is not working")

  try:
    m = f.meth(1,2)
    error = 1
  except:
    error = 0
  if error:  raise RuntimeError("Foo::meth ignore is not working")

  try:
    m = f.meth(1,2,3)
    error = 1
  except:
    error = 0
  if error:  raise RuntimeError("Foo::meth ignore is not working")

  if default_args.Klass.inc(100, default_args.Klass(22)).val != 122:
    raise RuntimeError("Klass::inc failed")

  if default_args.Klass.inc(100).val != 99:
    raise RuntimeError("Klass::inc failed")

  if default_args.Klass.inc().val != 0:
    raise RuntimeError("Klass::inc failed")

  default_args.trickyvalue1(10); default_args.trickyvalue1(10, 10)
  default_args.trickyvalue2(10); default_args.trickyvalue2(10, 10)
  default_args.trickyvalue3(10); default_args.trickyvalue3(10, 10)
  default_args.seek(); default_args.seek(10)

if __name__=="__main__":
  run('default_args')


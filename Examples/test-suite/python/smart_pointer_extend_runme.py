from smart_pointer_extend import *

f = Foo()
b = Bar(f)

if b.extension() != f.extension():
  raise RuntimeError


b = CBase()
d = CDerived()
p = CPtr()

if b.bar() != p.bar():
  raise RuntimeError

if d.foo() != p.foo():
  raise RuntimeError

if b.hello() != p.hello():
  raise RuntimeError




from python_kwargs import *

class MyFoo(Foo):
  def __init__(self, a , b = 0):
    Foo.__init__(self, a, b)

    

# Simple class
f1 = MyFoo(2)

f = Foo(b=2,a=1)

if f.foo(b=1,a=2) != 3:
  raise RuntimeError

if Foo_statfoo(b=2) != 3:
  raise RuntimeError

if f.efoo(b=2) != 3:
  raise RuntimeError

if Foo_sfoo(b=2) != 3:
  raise RuntimeError


# Templated class
b = BarInt(b=2,a=1)

if b.bar(b=1,a=2) != 3:
  raise RuntimeError

if BarInt_statbar(b=2) != 3:
  raise RuntimeError

if b.ebar(b=2) != 3:
  raise RuntimeError

if BarInt_sbar(b=2) != 3:
  raise RuntimeError


# Functions
if templatedfunction(b=2) != 3:
  raise RuntimeError

if foo(a=1,b=2) != 3:
  raise RuntimeError

if foo(b=2) != 3:
  raise RuntimeError


#Funtions with keywords

if foo_kw(_from=2) != 4:
  raise RuntimeError

if foo_nu(_from=2, arg2=3) != 2:
  raise RuntimeError

if foo_mm(min=2) != 4:
  raise RuntimeError

if foo_mm(max=3) != 4:
  raise RuntimeError
  

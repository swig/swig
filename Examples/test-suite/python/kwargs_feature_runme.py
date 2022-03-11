from kwargs_feature import *


class MyFoo(Foo):

    def __init__(self, a, b=0):
        Foo.__init__(self, a, b)


# Simple class
f1 = MyFoo(2)

f = Foo(b=2, a=1)

if f.foo(b=1, a=2) != 3:
    raise RuntimeError

if Foo.statfoo(b=2) != 3:
    raise RuntimeError

if Foo.statfoo_onearg(x=4) != 8:
    raise RuntimeError

if f.efoo(b=2) != 3:
    raise RuntimeError

if Foo.sfoo(b=2) != 3:
    raise RuntimeError


# Templated class
b = BarInt(b=2, a=1)

if b.bar(b=1, a=2) != 3:
    raise RuntimeError

if BarInt.statbar(b=2) != 3:
    raise RuntimeError

if b.ebar(b=2) != 3:
    raise RuntimeError

if BarInt.sbar(b=2) != 3:
    raise RuntimeError


# Functions
if templatedfunction(b=2) != 3:
    raise RuntimeError

if foo_fn(a=1, b=2) != 3:
    raise RuntimeError

if foo_fn(b=2) != 3:
    raise RuntimeError


# Functions with keywords

if foo_kw(_from=2) != 4:
    raise RuntimeError

if foo_nu(_from=2, arg2=3) != 2:
    raise RuntimeError

if foo_mm(min=2) != 4:
    raise RuntimeError

if foo_mm(max=3) != 4:
    raise RuntimeError

# Default args with references

if rfoo(n=123) != 120:
    raise RuntimeError

if rfoo(x=10) != -10:
    raise RuntimeError

if rfoo(n=11, x=22) != -11:
    raise RuntimeError

if rfoo(x=11, n=22) != 11:
    raise RuntimeError

# Extended constructors
e = Extending0()
e = Extending1(one=1)
e = Extending1(1)
e = Extending2(1, "two")
e = Extending2(1, two="two")
e = Extending2(two="two", one=1)
e = ExtendingOptArgs1()
e = ExtendingOptArgs1(1)
e = ExtendingOptArgs2(one=1)
e = ExtendingOptArgs2()
e = ExtendingOptArgs2(one=1)
e = ExtendingOptArgs2(two="two")
e = ExtendingOptArgs2(two="two", one=1)

# Invalid kwargs test
h = Hello()
try:
    h = Hello(nonexistent=10)
    raise RuntimeError("missed exception")
except TypeError as e:
    pass

f = Foo(1)
f = Foo(a=1)
try:
    f = Foo(nonexistent=10)
    raise RuntimeError("missed exception")
except TypeError as e:
    pass

try:
    f = Foo(a=1, nonexistent=10)
    raise RuntimeError("missed exception")
except TypeError as e:
    pass

try:
    f = Foo(1, nonexistent=10)
    raise RuntimeError("missed exception")
except TypeError as e:
    pass

# Varargs
f = VarargConstructor(fmt="Ciao")
f.vararg_method(fmt="Bonjour")
try:
    f = VarargConstructor(nonexistent="Ciao")
    raise RuntimeError("missed exception")
except TypeError as e:
    pass

try:
    f.vararg_method(nonexistent="Bonjour")
    raise RuntimeError("missed exception")
except TypeError as e:
    pass

import typename
import types
f = typename.Foo()
b = typename.Bar()

x = typename.twoFoo(f)
if not isinstance(x, float):
    raise RuntimeError("Wrong return type (FloatType) !")
y = typename.twoBar(b)
if not isinstance(y, int):
    raise RuntimeError("Wrong return type (IntType)!")

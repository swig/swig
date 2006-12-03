import typename
import types
f = typename.Foo()
b = typename.Bar()

x = typename.twoFoo(f)
if not isinstance(x,types.FloatType):
    print "Wrong return type!"
y = typename.twoBar(b)
if not isinstance(y,types.IntType):
    print "Wrong return type!"
    

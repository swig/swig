import extend_placement
import types

foo = extend_placement.Foo(1)
print type(foo)
print foo.spam()
print foo.spam("hello")

foo = extend_placement.Foo(1)
print type(foo)

from copyctor import *

bar = Bar()
bar = Bar(bar)

foo = Foo()
foo = Foo(bar)

car = Car()

hoo = Hoo()
hoo = Hoo(bar)
hoo = Hoo(car)

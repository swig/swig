from typedef_classforward_same_name import *

foo = Foo()
foo.x = 5
if extractFoo(foo) != 5:
    raise RuntimeError("unexpected value")

boo = Boo()
boo.x = 5
if extractBoo(boo) != 5:
    raise RuntimeError("unexpected value")

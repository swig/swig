require 'newobject1'

include Newobject1

foo1 = Foo.makeFoo
raise RuntimeError if Foo.fooCount != 1

foo2 = foo1.makeMore
raise RuntimeError if Foo.fooCount != 2

foo1 = nil ; GC.start
raise RuntimeError if Foo.fooCount != 1

foo2 = nil ; GC.start
raise RuntimeError if Foo.fooCount != 0

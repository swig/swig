require 'newobject3'

include Newobject3

foo1 = makeFoo
raise RuntimeError if fooCount != 1

foo2 = makeFoo
raise RuntimeError if fooCount != 2

foo1 = nil ; GC.start
raise RuntimeError if fooCount != 1

foo2 = nil ; GC.start
raise RuntimeError if fooCount != 0

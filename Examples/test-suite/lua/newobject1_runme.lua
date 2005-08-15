require("import")	-- the import fn
import("newobject1",true)	-- import code into global

foo1 = Foo_makeFoo()	-- lua doesnt yet support static fns properly
assert(Foo_fooCount() == 1)	-- lua doesnt yet support static fns properly

foo2 = foo1:makeMore()
assert(Foo_fooCount() == 2)

foo1 = nil 
collectgarbage()
assert(Foo_fooCount() == 1)

foo2 = nil 
collectgarbage()
assert(Foo_fooCount() == 0)

require("import")	-- the import fn
import("newobject1")	-- import code

foo1 = newobject1.Foo_makeFoo()	-- lua doesnt yet support static fns properly
assert(newobject1.Foo_fooCount() == 1)	-- lua doesnt yet support static fns properly

foo2 = foo1:makeMore()
assert(newobject1.Foo_fooCount() == 2)

foo1 = nil 
collectgarbage()
assert(newobject1.Foo_fooCount() == 1)

foo2 = nil 
collectgarbage()
assert(newobject1.Foo_fooCount() == 0)

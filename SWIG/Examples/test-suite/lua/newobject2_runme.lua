require("import")	-- the import fn
import("newobject2",true)	-- import code into global

foo1 = makeFoo()	-- lua doesnt yet support static fns properly
assert(fooCount() == 1)	-- lua doesnt yet support static fns properly

foo2 = makeFoo()
assert(fooCount() == 2)

foo1 = nil 
collectgarbage()
assert(fooCount() == 1)

foo2 = nil 
collectgarbage()
assert(fooCount() == 0)

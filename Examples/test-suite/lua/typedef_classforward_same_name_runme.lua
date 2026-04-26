local v=require("typedef_classforward_same_name")

local foo = v.Foo()
foo.x = 5
assert(v.extractFoo(foo) == 5)
local boo = v.Boo()
boo.x = 5
assert(v.extractBoo(boo) == 5)

require("typename")

local f = typename.Foo()
local b = typename.Bar()
local x = typename.twoFoo(f)
assert(type(x) == "number")
local y = typename.twoBar(b)
assert(type(y) == "number")

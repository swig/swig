require("typedef_scope")

local b = typedef_scope.Bar()
local x = b:test1(42, "hello")
assert(x == 42)
x = b:test2(42, "hello")
assert(x == "hello")

require("struct_value")

local b = struct_value.Bar()
b.a.x = 3
assert(b.a.x == 3)
b.b.x = 3
assert(b.b.x == 3)

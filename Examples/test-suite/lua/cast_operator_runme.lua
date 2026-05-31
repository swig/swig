require("cast_operator")

local a = cast_operator.A()
local t = a:tochar()
assert(t == "hi")

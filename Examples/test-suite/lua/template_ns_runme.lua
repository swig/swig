local v=require("template_ns")

local p1 = v.pairii(2, 3)
local p2 = v.pairii(p1)
assert(p2.first == 2)
assert(p2.second == 3)

local p3 = v.pairdd(3.5, 2.5)
local p4 = v.pairdd(p3)
assert(p4.first == 3.5)
assert(p4.second == 2.5)

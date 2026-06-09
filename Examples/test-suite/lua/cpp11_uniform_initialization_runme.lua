local v=require("cpp11_uniform_initialization")

local var1 = v.var1
assert(var1.x == 5)
local var2 = v.var2
assert(var2:getX() == 2)

local m = v.MoreInit()
assert(m.charptr == nil)
m.charptr = "hello sir"
assert(m.charptr == "hello sir")
assert(m:more1(m.vi) == 15)
-- assert(m:more1({-1, 1, 2}) == 2) TODO Lua do not convert table to std:vector<>
assert(m:more1() == 10)

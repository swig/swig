local v=require("template_function_parm")

local vi = v.VectorInt()
vi:push_back(10)
vi:push_back(20)
vi:push_back(30)
local myc = v.MyC()
local sum = myc:take_function(v.accumulate_integers, vi)
assert(sum == 60)

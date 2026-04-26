local v=require("derived_nested")

local outer = v.BB()
local d = v.BB.DD()
local e = v.BB.EE()
outer.ff_instance.z = outer.ff_instance.x
outer:useEE(e)

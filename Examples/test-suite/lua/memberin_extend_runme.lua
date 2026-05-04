local v=require("memberin_extend")

local em1 = v.ExtendMe()
local em2 = v.ExtendMe()
em1.thing = "em1thing"
em2.thing = "em2thing"
assert(em1.thing == "em1thing", "wrong: " .. em1.thing)
assert(em2.thing == "em2thing", "wrong: " .. em2.thing)

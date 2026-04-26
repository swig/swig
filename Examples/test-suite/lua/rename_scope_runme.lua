local v=require("rename_scope")

local a = v.Natural_UP()
local b = v.Natural_BP()
assert(a:rtest() == 1)
assert(b:rtest() == 1)

local v=require("virtual_vs_nonvirtual_base")

local fail = v.SimpleClassFail()
local work = v.SimpleClassWork()
assert(work:getInner():get() == fail:getInner():get())

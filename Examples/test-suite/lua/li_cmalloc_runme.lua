local v=require("li_cmalloc")

local p1 = v.malloc_int()
v.free_int(p1)

assert(not pcall(function()
	local p2 = v.calloc_int(-1)
	free_int(p2)
end))

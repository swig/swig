local v=require("li_std_vector_enum")

local ev = v.EnumVector()
assert(ev.nums[0] == 10)
assert(ev.nums[1] == 20)
assert(ev.nums[2] == 30)
assert(ev.nums:size() == 3)

local v=require("li_boost_shared_ptr_bits")

local vc = v.VectorIntHolder()
vc:push_back(v.IntHolder(11))
vc:push_back(v.IntHolder(22))
vc:push_back(v.IntHolder(33))

local sum = v.sum(vc)
assert(sum == 66, "sum is wrong")

local hidden = v.HiddenDestructor.create()
hidden = nil
collectgarbage()
local hiddenPrivate = v.HiddenPrivateDestructor.create()
assert(v.HiddenPrivateDestructor.DeleteCount == 0, "Count should be zero")
hiddenPrivate = nil
collectgarbage()
assert(v.HiddenPrivateDestructor.DeleteCount == 1, "Count should be one")

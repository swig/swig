require("ret_by_value")

local a = ret_by_value.get_test()
assert(a.myInt == 100)
assert(a.myShort == 200)

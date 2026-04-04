local v=require("naturalvar_more")

local s = v.S()
assert(s.const_string_member == "initial string value", "Test 1")
s.string_member = "some member value"
assert(s.string_member == "some member value", "Test 2")

local v=require("li_std_pair_using")

local one = v.StringStringPair()
one.first = "one"
one.second = "numero uno"

local two = v.StringIntPair()
two.first = "two"
two.second = 2

-- copy one
local b = v.bounce(one)
assert(not swig_equals(b, one))
assert(b.first == one.first)
assert(b.second == one.second)

-- copy two
local c = v.StringIntPair(two)
assert(c.first == two.first)
assert(c.second == two.second)

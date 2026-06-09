require("cpp11_decltype")

local a = cpp11_decltype.A()
a.i = 5
assert(a.i == 5, "Assignment to a:i failed.")
a.j = 10
assert(a.j == 10, "Assignment to a:j failed.")
local n = a:get_number(5)
assert(n == 10, "get_number(5) should return 10.")
n = a:get_number(6)
assert(n == 0, "get_number(6) should return 0.")

local b = cpp11_decltype.B()
assert(not b.a, "b.a should be false")
assert(b.b, "b.b should be true")
assert(not b:negate(true), "b.negate(true) should return false")
assert(b:negate(false), "b.negate(false) should return true")

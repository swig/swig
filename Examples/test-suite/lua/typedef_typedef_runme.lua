require("typedef_typedef")

local b = typedef_typedef.B()
assert(b:getValue(123) == 1234)

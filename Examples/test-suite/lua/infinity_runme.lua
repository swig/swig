local v = require("infinity")

v.initialise_MYINFINITY()
local my_infinity = v.INFINITY
assert(tostring(my_infinity) == "inf")
local ret_val = v.use_infinity(my_infinity)
assert(tostring(ret_val)== "inf")

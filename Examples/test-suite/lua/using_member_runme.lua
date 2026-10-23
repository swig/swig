local v=require("using_member")

-- Lua uses number for both float and integer
-- Lua can not differentiate, C/C++ must differentiate function names

local b = v.B()
assert(b:get(1) == 10)
-- assert(b:get(1) == 20)

local bb = v.BB()
assert(bb:greater(1) == 0)
-- assert(bb:greater(1) == 1)
assert(bb:great(true) == 2)

local cc = v.CC()
-- assert(cc:greater(10) == 0)
assert(cc:greater(10) == 1)
assert(cc:greater(true) == 20)

local dd = v.DD()
assert(dd:greater(10) == 0)
-- assert(dd:greater(10) == 1)
assert(dd:greaterstill(true) == 30)

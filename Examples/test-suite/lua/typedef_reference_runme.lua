local v=require("typedef_reference")

local int2 = v.copy_intp(2)
assert(2 == v.somefunc(int2),"somefunc")
local int3 = v.copy_intp(3)
assert(3 == v.otherfunc(int3),"otherfunc")
assert(swig_type(int3) == "int *")
assert(v.global_int == 1234)

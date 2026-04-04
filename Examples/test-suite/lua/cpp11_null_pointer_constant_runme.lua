local v=require("cpp11_null_pointer_constant")

local a = v.A()
assert(a._myA == nil, "a._myA is null")
local b = v.A()
assert(a._myA == b._myA, "both a._myA and b._myA are null")
a._myA = v.A()
assert(a._myA ~= nil, "a._myA is not null")
assert(swig_type(a._myA) == "A *", "a._myA is a pointer to 'A'")

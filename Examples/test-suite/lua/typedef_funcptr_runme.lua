local v=require("typedef_funcptr")

local a = 100
local b = 10
assert(v.do_op(a,b,typedef_funcptr.addf) == 110, "addf")
assert(v.do_op(a,b,typedef_funcptr.subf) == 90, "subf")
assert(v.do_op_typedef_int(a,b,typedef_funcptr.addf) == 110, "addf")
assert(v.do_op_typedef_int(a,b,typedef_funcptr.subf) == 90, "subf")
assert(v.do_op_typedef_Integer(a,b,typedef_funcptr.addf) == 110, "addf")
assert(v.do_op_typedef_Integer(a,b,typedef_funcptr.subf) == 90, "subf")

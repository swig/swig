local v=require("template_arg_typename")

local ufbb = v.UnaryFunction_bool_bool()
assert(swig_type(ufbb) == "UnaryFunction< bool,bool > *")
local bufb = v.BoolUnaryFunction_bool(nil)
assert(swig_type(bufb) == "BoolUnaryFunction< bool > *")

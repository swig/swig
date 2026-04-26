local v=require("function_typedef")

local addfunc = v.addfunc
assert(swig_type(addfunc) == "binop_t *|int (*)(int,int)")
assert(v.do_binop1(addfunc, 11, 22) == 33)
assert(v.do_binop2(addfunc, 17, 51) == 68)
assert(v.do_binop3(addfunc, 32, 47) == 79)

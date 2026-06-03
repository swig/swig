require("funcptr")

assert(funcptr.add(7, 9) == 16)
assert(funcptr.do_op(7, 9, funcptr.funcvar) == 16)

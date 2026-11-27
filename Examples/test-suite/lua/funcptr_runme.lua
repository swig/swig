require("funcptr")

assert(funcptr.add(7, 9) == 16)
assert(funcptr.do_op(7, 9, funcptr.funcvar) == 16)

-- A function pointer using bool
funcptr.funcvarbool = funcptr.funcvarbool
assert(funcptr.call_funcvarbool(1) == 1)
assert(funcptr.call_funcvarbool(0) == 0)

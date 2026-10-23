local v=require("default_args_c")

assert(v.foo1() == 1)
assert(v.foo43() == 43)

local f = v.FooStruct()
f:no_arg()
f:one_req(nil)
f:one_opt()
f:one_opt(nil)
f:two_arg(nil)
f:two_arg(nil, nil)

v.StaticStruct.no_arg()
v.StaticStruct.one_req(nil)
v.StaticStruct.one_opt()
v.StaticStruct.one_opt(nil)
v.StaticStruct.two_arg(nil)
v.StaticStruct.two_arg(nil, nil)

v.global_opts1()
v.global_opts1(nil)
v.global_opts2(nil)
v.global_opts2(nil, nil)

local v=require("compactdefaultargs")

local defaults1 = v.Defaults1(1000)
defaults1 = v.Defaults1()
assert(defaults1:ret(10.0) == 10.0)
assert(defaults1:ret() == -1.0)

local defaults2 = v.Defaults2(1000)
defaults2 = v.Defaults2()
assert(defaults2:ret(10.0) == 10.0)
assert(defaults2:ret() == -1.0)
assert(defaults2:nodefault(-2) == -2)

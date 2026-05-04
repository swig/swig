local v=require("preproc_defined")

assert(v.call_checking() == 1)
local d = v.Defined()
d.defined = 10

v.thing(10)
v.stuff(10)
v.bumpf(10)
assert(v.a == 2)
assert(v.b == 42)
assert(v.z == 8)

local v=require("abstract_virtual")

local d = v.D()
assert(d ~= nil)
assert(swig_type(d) == "D *")
local e = v.E()
assert(e ~= nil)
assert(swig_type(e) == "E *")

require("const_const_2")

local s1 = const_const_2.Spam()
assert(swig_type(s1) == "Spam *")
local e = const_const_2.Eggs()
assert(swig_type(e) == "Eggs *")
local s2 = e:spam()
assert(swig_type(s2) == "Spam *")

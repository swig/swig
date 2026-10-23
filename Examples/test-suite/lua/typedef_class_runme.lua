require("typedef_class")

local a = typedef_class.RealA()
a.a = 3
local b = typedef_class.B()
b:testA(a)

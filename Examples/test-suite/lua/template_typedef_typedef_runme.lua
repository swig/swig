local v=require("template_typedef_typedef")

local ob1 = v.Object1Base()
ob1:getBlabla1(v.Object1Base())
local ob2 = v.Object2Base()
ob2:getBlabla2(v.Object2Base())

local factory = v.Factory()
factory:getBlabla3(v.Object1Base())
factory:getBlabla4(v.Object2Base())

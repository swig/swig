local v=require("private_assign")

local three = v.Three()
local tn = three.TwoNot
local ti = three.TwoIs
three.TwoIs = v.TwoIsAssignableCopyable()

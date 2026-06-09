local v=require("cpp11_final_class")

local fc1 = v.FinalClass1()
fc1:method1()

local fc2 = v.FinalClass2()
fc2:method2()

local fc3 = v.FinalClass3()
fc3:method3()

local fc4 = v.FinalClass4()
fc4:method4()

local fc5 = v.FinalClass5()
fc5:method5()
fc5.final_member_var:finalmethod()
local fc5final = fc5:get_final_member()
fc5final:finalmethod()
fc5final = fc5:get_final_member2()
fc5final:finalmethod()

local fc6 = v.FinalClass6()
fc6:method6()
fc6:final()

local o = v.override()
o:omethod()

local y = v.Y()
local fv4 = v.FinalVar4()
local yy = fv4.final

local fv5 = v.FinalVar5()
yy = fv5.final

local fv6 = v.FinalVar6()
yy = fv6.final

local fv7 = v.FinalVar7()
yy = fv7.final

local fv8 = v.FinalVar8()
yy = fv8.final

local fv9 = v.FinalVar9()
yy = fv9.final

local fv10 = v.FinalVar10()
fv10:b10(y)

local s3f = v.Space3_final()
s3f:fmethod()

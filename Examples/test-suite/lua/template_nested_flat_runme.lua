local v=require("template_nested_flat")

v.T_NormalTemplateNormalClass():tmethod(v.NormalClass())
v.OuterClass():T_OuterTMethodNormalClass(v.NormalClass())

local tf = v.TemplateFuncs()
assert(tf:T_TemplateFuncs1Int(-10) == -10)
assert(tf:T_TemplateFuncs2Double(-12.3) == -12.3)

local tn = v.T_NestedOuterTemplateDouble()
assert(tn:hohum(-12.3) == -12.3)

local inner1 = v.OuterClass():useInner1(v.T_OuterClassInner1Int())
local inner2 = v.T_OuterClassInner2NormalClass()
inner2.embeddedVar = 2
local inner22 = v.OuterClass():useInner2Again(inner2)
local inner3 = v.T_OuterClassInner1Double()

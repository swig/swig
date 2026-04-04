local v=require("template_specialization_using_declaration")

local cc = v.ConcreteClass(11)

-- Base template tests
local bs = v.BaseTemplateString()
bs:method_primary("hi")
local cs = v.BaseTemplateConcreteClass()
cs:method_specialization(cc)
local bi = v.BaseTemplateInt()
bi:method_partial_specialization(22)

-- Derived template tests
local ds = v.DerivedTemplateString()
ds:method_primary("hi")
ds:method_primary_derived("hi")
ds:method_primary_hidden("hi")
local dc = v.DerivedTemplateConcreteClass()
dc:method_specialization(cc)
dc:method_specialization_derived(cc)
dc:method_specialization_hidden(cc)
local di = v.DerivedTemplateInt()
di:method_partial_specialization(22)
di:method_partial_specialization_derived(22)
di:method_partial_specialization_hidden(22)

local v=require("template_template_template_parameters")

local custom_attrs = v.CustomAttrs()
assert(swig_type(custom_attrs) == "CustomAttrs *")
local ac = v.AC()
local bac = v.BAC()
local cbac = v.CBAC()
local dbac = v.DBAC()

custom_attrs = ac.attributes
assert(swig_type(custom_attrs) == "CustomAttrs *")
custom_attrs = bac.attributes
assert(swig_type(custom_attrs) == "CustomAttrs *")
custom_attrs = cbac.attributes
assert(swig_type(custom_attrs) == "CustomAttrs *")
custom_attrs = dbac.attributes
assert(swig_type(custom_attrs) == "CustomAttrs *")

bac:BMethod(custom_attrs, ac)
cbac:BMethod(custom_attrs, ac)
dbac:BMethod(custom_attrs, ac)
cbac:CMethod(custom_attrs, bac)
dbac:DMethod(custom_attrs, bac)

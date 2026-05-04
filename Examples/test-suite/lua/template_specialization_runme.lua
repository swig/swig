local v=require("template_specialization")

local ufd = v.UnaryFunction_double()
ufd:negate()

local ufb = v.UnaryFunction_bool()
ufb:foo(ufb)
ufb:not1()

local osi = v.OnlySpecialized_int()
osi:bar(osi)

-- Type wrapper class not proxy class is returned as primary template definition is not seen by SWIG
local osd = template_specialization.factory(nil)

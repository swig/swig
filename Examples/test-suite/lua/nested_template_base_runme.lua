local v=require("nested_template_base")

local ois = v.InnerS(123)
local oic = v.InnerC()
-- Check base method is available
assert(oic:outer(ois).val == 123, "outer")
-- Check non-derived class using base class
assert(oic:innerc():outer(ois).val == 123, "innerc")

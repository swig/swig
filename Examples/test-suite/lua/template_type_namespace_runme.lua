local v=require("template_type_namespace")

local result = v.foo()
assert(result[0] == "foo")
assert(result:size() == 1)

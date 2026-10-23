local v=require("nested_scope_flat")

v.Global_()
v.Outer1()
local nested2 = v.Nested2()
nested2.data = 42
assert(nested2.data == 42)
v.Klass()
v.Real():Method()

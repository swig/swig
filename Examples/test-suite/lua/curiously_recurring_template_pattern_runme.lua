local v=require("curiously_recurring_template_pattern")

local d = v.Derived()
d:setBase1Param(1):setDerived1Param(10):setDerived2Param(20):setBase2Param(2)

assert(d:getBase1Param() == 1)
assert(d:getDerived1Param() == 10)
assert(d:getBase2Param() == 2)
assert(d:getDerived2Param() == 20)

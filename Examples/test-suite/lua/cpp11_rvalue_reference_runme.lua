require("cpp11_rvalue_reference")

local a = cpp11_rvalue_reference.A()

a:setAcopy(5)
assert(a:getAcopy() == 5, "int A::getAcopy() value is " .. a:getAcopy() .. " should be 5")

local ptr = a:getAptr()
a:setAptr(ptr)
assert(a:getAcopy() == 5, "after A::setAptr(): int A::getAcopy() value is " .. a:getAcopy() .. " should be 5")

a:setAref(ptr)
assert(a:getAcopy() == 5, "after A::setAref(): int A::getAcopy() value is " .. a:getAcopy() .. " should be 5")

local rvalueref = a:getAmove()
a:setAref(rvalueref)
assert(a:getAcopy() == 5, "after A::setAmove(): int A::getAcopy() value is " .. a:getAcopy() .. " should be 5")

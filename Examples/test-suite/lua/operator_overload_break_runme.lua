local v=require("operator_overload_break")

local op = v.Op(5)
assert(op ~= nil)
assert(swig_type(op) == "Op *")

assert(op - 3 == v.Op(2), "subtraction")
op.k = 37
assert(op + 3 == v.Op(40), "addition")
op.k = 22
assert(v.Op(32) - op == v.Op(10), "reversed subtraction")
assert(not (op == v.Op(3)), 'not equal')
assert(op ~= v.Op(3), 'direct not equal')
op.k = 3
--[[ Lua TODO %rename(PlusPlusPrefix) does not work
op:PlusPlusPrefix() -- = (++op)
assert(op == v.Op(4), "pre-increment operator")
op:PlusPlusPostfix() -- = (op++)
assert(op == v.Op(5), "post-increment operator")
local op2 = op:PlusPlusPrefix() -- = (++op)
op2 = op:PlusPlusPostfix() -- = (op++)
assert(op == v.Op(7) and op2 == v.Op(7), "multiple post-increments")
]]

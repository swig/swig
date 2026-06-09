require('example')

local a = 37
local b = 42

-- Now call our C function with a bunch of callbacks

print("Trying some C callback functions")
print("    a        = " .. a)
print("    b        = " .. b)
print("    ADD(a,b) = " .. example.do_op(a,b,example.ADD))
print("    SUB(a,b) = " .. example.do_op(a,b,example.SUB))
print("    MUL(a,b) = " .. example.do_op(a,b,example.MUL))

print("Here is what the C callback function objects look like in Lua")
print("    ADD      = " .. type(example.ADD))
print("    SUB      = " .. type(example.SUB))
print("    MUL      = " .. type(example.MUL))

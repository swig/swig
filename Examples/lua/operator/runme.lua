-- Operator overloading example
require('example')

local a = example.Complex(2, 3)
local b = example.Complex(-5, 10)

print("a   =", a)
print("b   =", b)

local c = a + b
print("c   =", c)
print("a*b =", (a*b))
print("a-c =", (a-c))

-- This should invoke Complex's copy constructor
local e = example.Complex(a-c)
e = a - c
print("e   =", e)

-- Big expression
local f = ((a+b)*(c+b*e)) + (-a)
print("f   = ", f)

require("example")

-- Call our gcd() function

local x = 42
local y = 105
local g = example.gcd(x, y)
print(string.format("The gcd of %d and %d is %d", x, y, g))

-- Call our fact() function
local x = 5
g = example.fact(x)
print(string.format("The fact of %d is %d", x, g))

-- Manipulate the Foo global variable

-- Output its current value
print("Foo = " .. example.Foo)

-- Change its value
example.Foo = 3.1415926

-- See if the change took effect
print("Foo = " .. example.Foo)

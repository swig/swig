-- This file illustrates the manipulation of C++ references in Lua.
require 'example'

-- ----- Object creation -----

print("Creating some objects:")
local a = example.Vector(3,4,5)
local b = example.Vector(10,11,12)

print("    Created ", a:print())
print("    Created ", b:print())

-- ----- Call an overloaded operator -----

-- This calls the wrapper we placed around
--
--      operator+(const Vector &a, const Vector &)
--
-- It returns a new allocated object.

print("Adding a+b")
local c = example.addv(a, b)
print("    a+b = ", c:print())

-- ----- Create a vector array -----

print("Creating an array of vectors")
local va = example.VectorArray(10)
print("    va",  va)

-- ----- Set some values in the array -----

-- These operators copy the value of a and b to the vector array
va:set(0, a)
va:set(1, b)

va:set(2, example.addv(a,b))

local c = example.addv(a,b)
va:set(3, c)

-- Get some values from the array

print("Getting some array values")
for i=0,5 do
  print(string.format("    va(%d) = ", i), va:get(i):print())
end

-- Watch under resource meter to check on this
print("Making sure we don't leak memory.")
for i=0,1000000 do
  c = va:get(i % 10)
end

require("example")

-- Create a couple of a vectors

local v = example.new_Vector(1, 2, 3)
local w = example.new_Vector(10, 11, 12)

print("I just created the following vectors")
example.vector_print(v)
example.vector_print(w)

-- Now call some of our functions

print("\nNow I'm going to compute the dot product")
local d = example.dot_product(v,w)
print(string.format("dot product = %d (should be 68)", d))

-- Add the vectors together

print("\nNow I'm going to add the vectors together")
local r = example.vector_add(v,w)
example.vector_print(r)
print("The value should be (11, 13, 15)")

-- Now I'd better clean up the return result r

print("\nNow I'm going to clean up the return result")
example.free(r)

print("Good")

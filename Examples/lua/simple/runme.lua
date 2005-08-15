-- file: runme.lua

-- importing (lua doesnt have a nice way to do this)
if example==nil then 
	assert(loadlib("example.dll","Example_Init"))()
end

-- Call our gcd() function
print("hello world")

x = 42
y = 105
g = example.gcd(x,y)
print("The gcd of",x,"and",y,"is",g)

-- Manipulate the Foo global variable

-- Output its current value
print("Foo = ", example.Foo)

-- Change its value
example.Foo = 3.1415926

-- See if the change took effect
print("Foo = ", example.Foo)










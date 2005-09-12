-- file: runme.lua

-- importing (lua does not have a nice way to do this)
loadlibrary = loadlib("example.so","Example_Init")
if loadlibrary == nil then
    loadlibrary = loadlib("example.dll","Example_Init")
end
assert(loadlibrary, "could not find dynamic libray")
loadlibrary()

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










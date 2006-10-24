-- Operator overloading example
---- importing ----
if string.sub(_VERSION,1,7)=='Lua 5.0' then
	-- lua5.0 doesnt have a nice way to do this
	lib=loadlib('example.dll','Example_Init') or loadlib('example.so','Example_Init')
	assert(lib)()
else
	-- lua 5.1 does
	require('example')
end

a = example.intSum(0)
b = example.doubleSum(100.0)

-- Use the objects.  They should be callable just like a normal
-- lua function.

for i=0,100 do
    a(i)                -- Note: function call
    b(math.sqrt(i))     -- Note: function call
end 
print(a:result())   -- should be 5050
print(b:result())   -- should be ~771.46


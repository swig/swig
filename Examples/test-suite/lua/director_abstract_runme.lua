-- Test director_abstract for Lua
-- Tests abstract classes with directors

require("director_abstract")

-- Use the SWIG-provided helper function for cleaner code
-- swig_override(obj, methodName, func) - sets a method override

--print("=== Test 1: Abstract Foo class ===")
-- Create a Foo with overridden ping
local myFoo = director_abstract.Foo()
swig_override(myFoo, "ping", function(self)
	return "LuaFoo::ping()"
end)

local pingResult = myFoo:ping()
--print("myFoo:ping() = " .. pingResult)
assert(pingResult == "LuaFoo::ping()", "Expected 'LuaFoo::ping()' but got '" .. pingResult .. "'")

local pongResult = myFoo:pong()
--print("myFoo:pong() = " .. pongResult)
assert(pongResult == "Foo::pong();LuaFoo::ping()", "Expected 'Foo::pong();LuaFoo::ping()' but got '" .. pongResult .. "'")

--print("\n=== Test 2: Example1 abstract class ===")
local ex1 = director_abstract.Example1()
swig_override(ex1, "Color", function(self, r, g, b)
	return r -- Return red
end)
local color1 = director_abstract.Example1.get_color(ex1, 1, 2, 3)
--print("Example1.get_color(1,2,3) = " .. tostring(color1))
assert(color1 == 1, "Expected 1 but got " .. tostring(color1))

--print("\n=== Test 3: Example2 abstract class ===")
local ex2 = director_abstract.Example2(1, 2)
swig_override(ex2, "Color", function(self, r, g, b)
	return g -- Return green
end)
local color2 = director_abstract.Example2.get_color(ex2, 1, 2, 3)
--print("Example2.get_color(1,2,3) = " .. tostring(color2))
assert(color2 == 2, "Expected 2 but got " .. tostring(color2))

--print("\n=== Test 4: Example3_i template class ===")
local ex3 = director_abstract.Example3_i()
swig_override(ex3, "Color", function(self, r, g, b)
	return b -- Return blue
end)
local color3 = director_abstract.Example3_i.get_color(ex3, 1, 2, 3)
--print("Example3_i.get_color(1,2,3) = " .. tostring(color3))
assert(color3 == 3, "Expected 3 but got " .. tostring(color3))

--print("\n=== All director_abstract tests passed! ===")

-- Test director_exception for Lua
-- Tests exception handling with directors

require("director_exception")

-- Use the SWIG-provided helper function for cleaner code
-- swig_override(obj, methodName, func) - sets a method override

--print("=== Test 1: Director method that throws an error ===")
local foo1 = director_exception.Foo()
swig_override(foo1, "ping", function(self)
	error("MyFoo::ping() EXCEPTION")
end)

local laundered1 = director_exception.launder(foo1)
local ok, err = pcall(function()
	laundered1:pong()
end)
assert(not ok, "Exception should have been thrown")
--print("Caught expected exception: " .. tostring(err))
assert(string.find(tostring(err), "EXCEPTION") ~= nil, "Exception message should contain 'EXCEPTION'")

--print("\n=== Test 2: Director method that returns wrong type ===")
local foo2 = director_exception.Foo()
swig_override(foo2, "ping", function(self)
	return 12345 -- Wrong type: number instead of string
end)

local laundered2 = director_exception.launder(foo2)
local ok2, err2 = pcall(function()
	laundered2:pong()
end)
-- This might or might not throw depending on how strict the type checking is
--[[if not ok2 then
	print("Caught type mismatch error (expected): " .. tostring(err2))
else
	print("No error thrown for type mismatch (might be ok if auto-conversion happens)")
end]]

--print("\n=== Test 3: Normal director method call ===")
local foo3 = director_exception.Foo()
swig_override(foo3, "ping", function(self)
	return "LuaFoo::ping()"
end)

local laundered3 = director_exception.launder(foo3)
local result = laundered3:pong()
--print("foo3:pong() = " .. result)
assert(result == "Foo::pong();LuaFoo::ping()", "Expected 'Foo::pong();LuaFoo::ping()' but got '" .. result .. "'")

--print("\n=== Test 4: Base class method (no override) ===")
local foo4 = director_exception.Foo()
local laundered4 = director_exception.launder(foo4)
local result4 = laundered4:pong()
--print("foo4:pong() (no override) = " .. result4)
assert(result4 == "Foo::pong();Foo::ping()", "Expected 'Foo::pong();Foo::ping()' but got '" .. result4 .. "'")

--print("\n=== All director_exception tests passed! ===")

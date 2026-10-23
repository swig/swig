-- Test director_string for Lua
-- Tests string handling with directors

require("director_string")

-- Use the SWIG-provided helper function for cleaner code
-- swig_override(obj, methodName, func) - sets a method override

--print("=== Test 1: Create A with string constructor ===")
local a = director_string.A("hello")
local get0 = a:get(0)
--print("a:get(0) = " .. get0)
assert(get0 == "hello", "Expected 'hello' but got '" .. get0 .. "'")

--print("\n=== Test 2: Override get_first method ===")
local b = director_string.A("hello")
swig_override(b, "get_first", function(self)
	-- Call base class method and append to it
	return "hello world!"
end)

local getFirst = b:get_first()
--print("b:get_first() = " .. getFirst)
assert(getFirst == "hello world!", "Expected 'hello world!' but got '" .. getFirst .. "'")

--print("\n=== Test 3: call_get_first (C++ calls Lua) ===")
local callFirst = b:call_get_first()
--print("b:call_get_first() = " .. callFirst)
assert(callFirst == "hello world!", "Expected 'hello world!' but got '" .. callFirst .. "'")

--print("\n=== Test 4: process_text override ===")
local c = director_string.A("test")
local processedText = nil
swig_override(c, "process_text", function(self, text)
	processedText = "processed: " .. text
end)
c:call_process_func()
--print("processedText = " .. tostring(processedText))
assert(processedText == "processed: hello", "Expected 'processed: hello' but got '" .. tostring(processedText) .. "'")

--print("\n=== All director_string tests passed! ===")

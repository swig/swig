require("import")             -- the import fn
import("director_enum", true) -- import lib with global

-- Test director with enum parameters

-- Create a derived class that overrides say_hi
MyFoo = {}
MyFoo.__index = MyFoo
setmetatable(MyFoo, { __index = director_enum.Foo })

function MyFoo:new()
	local obj = director_enum.Foo()
	-- Use SWIG-provided helper to set multiple overrides at once
	swig_derive(obj, {
		say_hi = function(self, val)
			return val
		end
	})
	return obj
end

-- Create instances
local b = director_enum.Foo()
local a = MyFoo:new()

-- Test enum handling through director
-- a.say_hi should return the value passed to it
-- b.say_hello should swap hi <-> hello
local result_a = a:say_hi(director_enum.hello)
local result_b = b:say_hello(director_enum.hi)

-- say_hello(hi) should return hello (it swaps)
-- say_hi(hello) should return hello (our override just returns the value)
-- So both should be equal to 'hello'
assert(result_a == result_b, "enum director test failed: expected same result")
assert(result_a == director_enum.hello, "expected hello enum value")

--print("All director_enum tests passed!")

-- Test director_basic for Lua
-- This tests the basic director functionality including method overrides

require("director_basic")

-- Use the SWIG-provided helper function for cleaner code
-- swig_override(obj, methodName, func) - sets a method override
-- swig_derive(obj, {method1=func1, ...}) - sets multiple overrides at once

--print("=== Test 1: Base Foo object (no override) ===")
local b = director_basic.Foo()
local ping_result = b:ping()
--print("b:ping() = " .. ping_result)
assert(ping_result == "Foo::ping()", "Expected 'Foo::ping()' but got '" .. ping_result .. "'")

local pong_result = b:pong()
--print("b:pong() = " .. pong_result)
assert(pong_result == "Foo::pong();Foo::ping()", "Expected 'Foo::pong();Foo::ping()' but got '" .. pong_result .. "'")

--print("\n=== Test 2: Foo with overridden ping() method ===")
-- Create a Foo and override the ping method
local myFoo = director_basic.Foo()
swig_override(myFoo, "ping", function(self)
	return "LuaFoo::ping()"
end)

local myPing = myFoo:ping()
--print("myFoo:ping() = " .. myPing)
assert(myPing == "LuaFoo::ping()", "Expected 'LuaFoo::ping()' but got '" .. myPing .. "'")

-- Test that pong() calls our overridden ping()
local myPong = myFoo:pong()
--print("myFoo:pong() = " .. myPong)
assert(myPong == "Foo::pong();LuaFoo::ping()", "Expected 'Foo::pong();LuaFoo::ping()' but got '" .. myPong .. "'")

--print("\n=== Test 3: Test get_self returns same director object ===")
local selfFoo = director_basic.Foo.get_self(myFoo)
local selfPing = selfFoo:ping()
--print("selfFoo:ping() = " .. selfPing)
assert(selfPing == "LuaFoo::ping()", "get_self should return object with Lua override, got '" .. selfPing .. "'")

--print("\n=== Test 4: Test A1 class ===")
local a = director_basic.A1(1)
local rg_result = a:rg(2)
--print("a:rg(2) = " .. tostring(rg_result))
assert(rg_result == 2, "Expected 2 but got " .. tostring(rg_result))

--print("\n=== Test 5: Test MyClass with vmethod override ===")
local bar = director_basic.Bar(3)
--print("Initial bar.x = " .. tostring(bar.x))
assert(bar.x == 3, "Expected bar.x == 3")

-- Test base MyClass behavior
local d = director_basic.MyClass()
local bd = d:cmethod(bar)
--print("Base MyClass: bd.x = " .. tostring(bd.x) .. " (should be 3 + 13 = 16)")
assert(bd.x == 16, "Expected bd.x == 16 but got " .. tostring(bd.x))

-- Create MyClass with overridden vmethod
local myClass = director_basic.MyClass()
swig_override(myClass, "vmethod", function(self, b)
	b.x = b.x + 31 -- Add 31 instead of 13
	return b
end)

local bar2 = director_basic.Bar(3)
local bc = myClass:cmethod(bar2)
--print("Lua MyClass: bc.x = " .. tostring(bc.x) .. " (should be 3 + 31 = 34)")
assert(bc.x == 34, "Expected bc.x == 34 but got " .. tostring(bc.x))

--print("\n=== Test 6: Test get_self with MyClass ===")
local selfClass = director_basic.MyClass.get_self(myClass)
local bar3 = director_basic.Bar(5)
local bc2 = selfClass:cmethod(bar3)
--print("get_self MyClass: bc2.x = " .. tostring(bc2.x) .. " (should be 5 + 31 = 36)")
assert(bc2.x == 36, "Expected bc2.x == 36 but got " .. tostring(bc2.x))

--print("\n=== Test 7: Multiple objects with different overrides ===")
local foo1 = director_basic.Foo()
local foo2 = director_basic.Foo()
swig_override(foo1, "ping", function(self) return "Foo1::ping()" end)
swig_override(foo2, "ping", function(self) return "Foo2::ping()" end)

assert(foo1:ping() == "Foo1::ping()", "foo1 override failed")
assert(foo2:ping() == "Foo2::ping()", "foo2 override failed")
assert(foo1:pong() == "Foo::pong();Foo1::ping()", "foo1 pong failed")
assert(foo2:pong() == "Foo::pong();Foo2::ping()", "foo2 pong failed")
--print("Multiple independent overrides work correctly")

--print("\n=== Test 8: Test swig_get_override helper function ===")
-- Test getting override from object that has never had any override (no uservalue)
local freshFoo = director_basic.Foo()
local noOverride = swig_get_override(freshFoo, "ping")
assert(noOverride == nil, "Expected nil for object with no overrides, got " .. tostring(noOverride))
--print("swig_get_override returns nil for object without overrides")

-- Test getting non-existent override from object that has other overrides
swig_override(freshFoo, "ping", function(self) return "test" end)
local wrongMethod = swig_get_override(freshFoo, "nonExistentMethod")
assert(wrongMethod == nil, "Expected nil for non-existent method override")
--print("swig_get_override returns nil for non-existent method")

-- Test getting existing override
local existingOverride = swig_get_override(freshFoo, "ping")
assert(type(existingOverride) == "function", "Expected function for existing override")
assert(existingOverride(freshFoo) == "test", "Override function should work correctly")
--print("swig_get_override returns correct function for existing override")

--print("\n=== Test 9: Test swig_derive helper function ===")
-- Test swig_derive on fresh object (no existing uservalue)
local derivedFoo = director_basic.Foo()
swig_derive(derivedFoo, {
	ping = function(self) return "DerivedFoo::ping()" end
})
assert(derivedFoo:ping() == "DerivedFoo::ping()", "swig_derive should set override")
--print("swig_derive works on fresh object")

-- Test swig_derive adds to existing overrides
local anotherFoo = director_basic.Foo()
swig_override(anotherFoo, "ping", function(self) return "First" end)
swig_derive(anotherFoo, {
	pong = function(self) return "CustomPong" end -- Note: pong doesn't exist as virtual, this tests the mechanism
})
assert(swig_get_override(anotherFoo, "ping") ~= nil, "Original override should still exist")
--print("swig_derive preserves existing overrides")

--print("\n=== Test 10: Test removing override with nil ===")
local removableFoo = director_basic.Foo()
swig_override(removableFoo, "ping", function(self) return "Overridden" end)
assert(removableFoo:ping() == "Overridden", "Override should work before removal")

-- Remove the override by setting to nil
swig_override(removableFoo, "ping", nil)
local afterRemoval = removableFoo:ping()
assert(afterRemoval == "Foo::ping()", "After removing override, should call base class. Got: " .. afterRemoval)
--print("Removing override with nil works correctly")

--print("\n=== Test 11: Test chaining of swig_override ===")
local chainFoo = director_basic.Foo()
local returned = swig_override(chainFoo, "ping", function(self) return "Chained" end)
assert(returned == chainFoo, "swig_override should return the object for chaining")
--print("swig_override returns object for chaining")

--print("\n=== All director_basic tests passed! ===")

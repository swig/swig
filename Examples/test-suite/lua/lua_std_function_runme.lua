-- Test std_function support for Lua
-- Tests that Lua functions can be passed directly where C++ std::function is expected

require("lua_std_function")

-- ============================================================
-- Test 1: Basic int callback (by value)
-- ============================================================
local result = lua_std_function.callIntCallback(function(x) return x * 2 end, 21)
assert(result == 42, "Test 1 failed: Expected 42 but got " .. tostring(result))

-- ============================================================
-- Test 2: Void callback (no args, no return)
-- ============================================================
local was_called = false
lua_std_function.callVoidCallback(function()
	was_called = true
end)
assert(was_called, "Test 2 failed: Void callback was not called")

-- ============================================================
-- Test 3: String callback
-- ============================================================
result = lua_std_function.callStringCallback(function(s)
	return s .. " world"
end, "hello")
assert(result == "hello world", "Test 3 failed: Expected 'hello world' but got '" .. tostring(result) .. "'")

-- ============================================================
-- Test 4: Bool callback
-- ============================================================
result = lua_std_function.callBoolCallback(function(b) return not b end, true)
assert(result == false, "Test 4 failed: Expected false but got " .. tostring(result))

result = lua_std_function.callBoolCallback(function(b) return not b end, false)
assert(result == true, "Test 4b failed: Expected true but got " .. tostring(result))

-- ============================================================
-- Test 5: Double callback
-- ============================================================
result = lua_std_function.callDoubleCallback(function(x) return x * 1.5 end, 10.0)
assert(math.abs(result - 15.0) < 0.001, "Test 5 failed: Expected 15.0 but got " .. tostring(result))

-- ============================================================
-- Test 6: Multi-argument callback
-- ============================================================
result = lua_std_function.callMultiArgCallback(
	function(a, b, c) return a + b + #c end,
	10, 20.5, "abc"
)
assert(math.abs(result - 33.5) < 0.001, "Test 6 failed: Expected 33.5 but got " .. tostring(result))

-- ============================================================
-- Test 7: Callback by const reference
-- ============================================================
result = lua_std_function.callIntCallbackConstRef(function(x) return x * 3 end, 7)
assert(result == 21, "Test 7 failed: Expected 21 but got " .. tostring(result))

-- ============================================================
-- Test 8: Callback by rvalue reference
-- ============================================================
result = lua_std_function.callIntCallbackRvalueRef(function(x) return x + 100 end, 42)
assert(result == 142, "Test 8 failed: Expected 142 but got " .. tostring(result))

-- ============================================================
-- Test 9: Callback by pointer (non-nil)
-- ============================================================
result = lua_std_function.callIntCallbackPtr(function(x) return x * 5 end, 3)
assert(result == 15, "Test 9 failed: Expected 15 but got " .. tostring(result))

-- ============================================================
-- Test 10: Callback by pointer (nil => returns -1)
-- ============================================================
result = lua_std_function.callIntCallbackPtr(nil, 3)
assert(result == -1, "Test 10 failed: Expected -1 but got " .. tostring(result))

-- ============================================================
-- Test 11: Storing a callback in a class (by value)
-- ============================================================
local holder = lua_std_function.CallbackHolder()
assert(holder:hasCallback() == false, "Test 11a failed: Should have no callback initially")

holder:setCallback(function(x) return x + 100 end)
assert(holder:hasCallback() == true, "Test 11b failed: Should have callback after set")
result = holder:callCallback(42)
assert(result == 142, "Test 11c failed: Expected 142 but got " .. tostring(result))

-- ============================================================
-- Test 12: Storing a callback in a class (by const ref)
-- ============================================================
local holder2 = lua_std_function.CallbackHolder()
holder2:setCallbackConstRef(function(x) return x * 10 end)
result = holder2:callCallback(5)
assert(result == 50, "Test 12 failed: Expected 50 but got " .. tostring(result))

-- ============================================================
-- Test 13: Storing a callback in a class (by rvalue ref)
-- ============================================================
local holder3 = lua_std_function.CallbackHolder()
holder3:setCallbackRvalue(function(x) return x - 1 end)
result = holder3:callCallback(10)
assert(result == 9, "Test 13 failed: Expected 9 but got " .. tostring(result))

-- ============================================================
-- Test 14: Getting a std::function FROM C++ and calling it
-- ============================================================
local doubler = lua_std_function.makeDoubler()
result = doubler(21)
assert(result == 42, "Test 14 failed: Expected 42 but got " .. tostring(result))

local adder5 = lua_std_function.makeAdder(5)
result = adder5(37)
assert(result == 42, "Test 14b failed: Expected 42 but got " .. tostring(result))

-- ============================================================
-- Test 15: Void callback with arguments
-- ============================================================
lua_std_function.resetVoidCallbackCounter()
assert(lua_std_function.getVoidCallbackCounter() == 0, "Test 15a failed: Counter should be 0")

lua_std_function.callVoidIntCallback(function(x)
	-- Call the C++ increment function x times
	for i = 1, x do
		lua_std_function.incrementVoidCallbackCounter()
	end
end, 3)

assert(lua_std_function.getVoidCallbackCounter() == 3,
	"Test 15b failed: Expected 3 but got " .. tostring(lua_std_function.getVoidCallbackCounter()))

-- ============================================================
-- Test 16: Multiple callbacks as arguments
-- ============================================================
result = lua_std_function.callTwoCallbacks(
	function(x) return x * 2 end,
	function(x) return x * 3 end,
	10
)
assert(result == 50, "Test 16 failed: Expected 50 but got " .. tostring(result))

-- ============================================================
-- Test 17: Closures as callbacks (capture Lua local variables)
-- ============================================================
local multiplier = 7
result = lua_std_function.callIntCallback(function(x)
	return x * multiplier
end, 6)
assert(result == 42, "Test 17 failed: Expected 42 but got " .. tostring(result))

-- ============================================================
-- Test 18: Callback that returns a string with special characters
-- ============================================================
result = lua_std_function.callStringCallback(function(s)
	return string.upper(s) .. "!!!"
end, "test")
assert(result == "TEST!!!", "Test 18 failed: Expected 'TEST!!!' but got '" .. tostring(result) .. "'")

-- ============================================================
-- Test 19: Different callbacks stored in different holders
-- ============================================================
local h1 = lua_std_function.CallbackHolder()
local h2 = lua_std_function.CallbackHolder()
h1:setCallback(function(x) return x + 1 end)
h2:setCallback(function(x) return x + 2 end)
assert(h1:callCallback(10) == 11, "Test 19a failed")
assert(h2:callCallback(10) == 12, "Test 19b failed")

-- ============================================================
-- Test 20: Manual handler creation (advanced usage)
-- ============================================================
local handler = lua_std_function.IntCallback()
swig_override(handler, "Invoke", function(self, x) return x * 99 end)
local native = lua_std_function.IntCallbackNative(handler)
result = native(7)
assert(result == 693, "Test 20 failed: Expected 693 but got " .. tostring(result))

-- ============================================================
-- Test 21: Replacing a stored callback
-- ============================================================
local h = lua_std_function.CallbackHolder()
h:setCallback(function(x) return x + 1 end)
assert(h:callCallback(5) == 6, "Test 21a failed")
h:setCallback(function(x) return x + 2 end)
assert(h:callCallback(5) == 7, "Test 21b failed")

-- ============================================================
-- Test 22: Pass an existing NameNative to a function expecting std::function
-- ============================================================
local native_fn = lua_std_function.makeDoubler()
result = lua_std_function.callIntCallback(native_fn, 21)
assert(result == 42, "Test 22 failed: Expected 42 but got " .. tostring(result))

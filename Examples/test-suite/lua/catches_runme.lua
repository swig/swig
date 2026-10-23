local v=require("catches")

function test(func, expected)
  local err, msg = pcall(func)
  assert(not err, "Failed to propagate C++ exception. Expected '" ..
    expected .. "', but no exception was thrown.")
  assert(type(msg) == type(expected), "Failed to propagate C++ proper exception type. " ..
    "Expected " ..  type(expected) .. ", but received " .. type(msg) .. ".")
  assert(msg == expected, "Failed to propagate C++ exception. Expected '" ..
    expected .. "', but received '" .. msg .. "'.")
end

-- unknown exception from SWIG value
local unknown_exception="SWIG_RuntimeError:unknown exception"

test(function() v.test_catches(1) end, 1) -- the exception is a number!
test(function() v.test_catches(2) end, "two")
test(function() v.test_catches(3) end, "object exception:ThreeException *")

test(function() v.test_exception_specification(1) end, 1) -- the exception is a number!
test(function() v.test_exception_specification(2) end, unknown_exception)
test(function() v.test_exception_specification(3) end, unknown_exception)

test(function() v.test_catches_all(1) end, unknown_exception)

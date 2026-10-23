local v=require("apply_strings")

local test_message = "A message from target language to the C++ world and back again."

assert(v.UCharFunction(test_message) == test_message, "UCharFunction")
assert(v.SCharFunction(test_message) == test_message, "SCharFunction")
assert(v.CUCharFunction(test_message) == test_message, "CUCharFunction")
assert(v.CSCharFunction(test_message) == test_message, "CSCharFunction")

local d = v.DirectorTest()
assert(d:UCharFunction(test_message) == test_message, "UCharFunction")
assert(d:SCharFunction(test_message) == test_message, "SCharFunction")
assert(d:CUCharFunction(test_message) == test_message, "CUCharFunction")
assert(d:CSCharFunction(test_message) == test_message, "CSCharFunction")

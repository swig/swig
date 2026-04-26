require("using_pointers")

local f = using_pointers.FooBar()
local ret, msg = pcall(function() f:exception_spec(1) end)
assert(not ret)
assert(msg == 10)
ret, msg =pcall(function() f:exception_spec(2) end)
assert(not ret)
assert(msg == "exception message")

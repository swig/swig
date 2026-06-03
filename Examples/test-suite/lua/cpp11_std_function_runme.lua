require("cpp11_std_function")

local fn = cpp11_std_function.pass_checker(420)

-- invoke functor via call method
assert(fn:call(420, "Petka"), "Petka 420 should be true")
assert(not fn:call(419, "Chapai"), "Chapai 419 should be false")

-- call wrapper
assert(cpp11_std_function.call_function(fn, 420, "Petka"), "Petka 420 should be true")
assert(not cpp11_std_function.call_function(fn, 419, "Chapai"), "Chapai 419 should be false")

-- NULL handling
assert(not pcall(function()
  cpp11_std_function.call_function(nil, 420, "Petka")
end), "call_function accepted invalid argument")

-- Invalid argument
assert(not pcall(function()
  cpp11_std_function.call_function("invalid", 420, "Petka")
end), "call_function accepted invalid argument")

require("import")
import("cpp11_std_function")

local fn = cpp11_std_function.pass_checker(420)

-- invoke functor via call method
if not fn:call(420, "Petka") then
  error("Petka 420 should be true")
end

if fn:call(419, "Chapai") then
  error("Chapai 419 should be false")
end

-- call wrapper
if not cpp11_std_function.call_function(fn, 420, "Petka") then
  error("Petka 420 should be true")
end

if cpp11_std_function.call_function(fn, 419, "Chapai") then
  error("Chapai 419 should be false")
end

-- NULL handling
local passed = pcall(function()
  cpp11_std_function.call_function(nil, 420, "Petka")
end)
if passed then
  error("call_function accepted invalid argument")
end

-- Invalid argument
local passed = pcall(function()
  cpp11_std_function.call_function("invalid", 420, "Petka")
end)
if passed then
  error("call_function accepted invalid argument")
end

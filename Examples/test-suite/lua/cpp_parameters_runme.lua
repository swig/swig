local v=require("cpp_parameters")

-- Testing correct and incorrect parameter counts being passed (kwargs and non-kwargs)
-- Note that the implementation depends a lot on whether zero, one, two or more args are being wrapped

-- Zero parameters expected
local x = v.Zero()
assert(not pcall(function() v.Zero(0) end))
assert(not pcall(function() x.zero(0) end))
assert(not pcall(function() v.Zero.stat_zero(0) end))
assert(not pcall(function() v.global_zero(0) end))

-- One mandatory parameter expected
x = v.One(1)
assert(not pcall(function() v.One(1, 0) end))
assert(not pcall(function() x:one(1, 0) end))
assert(not pcall(function() v.One.stat_one(1, 0) end))
assert(not pcall(function() v.global_one(1, 0) end))

-- Two mandatory parameters expected
x = v.Two(1, 2)
assert(not pcall(function() v.Two(1, 2, 0) end))
assert(not pcall(function() x:two(1, 2, 0) end))
assert(not pcall(function() v.Two.stat_two(1, 2, 0) end))
assert(not pcall(function() v.global_two(1, 2, 0) end))

-- Single optional parameter expected
x = v.Single(1)
assert(not pcall(function() v.Single(1, 0) end))
assert(not pcall(function() x:single(1, 0) end))
assert(not pcall(function() v.Single.stat_single(1, 0) end))
assert(not pcall(function() v.global_single(1, 0) end))

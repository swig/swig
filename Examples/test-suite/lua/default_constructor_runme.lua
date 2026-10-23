local v=require("default_constructor")

-- This should be no problem
local a = v.A()

-- Nor should this
local aa = v.AA()

-- The default constructor for B is private, so this should raise an exception
assert(not pcall(function() v.B() end))

-- The two-argument constructor for B should work
local b = v.B(3, 4)

-- BB shouldn't inherit B's default constructor, so this should raise an exception
assert(not pcall(function() v.BB() end))

-- C's constructor is protected, so this should raise an exception
assert(not pcall(function() v.C() end))

-- CC gets a default constructor, so no problem here
local cc = v.CC()

-- D's constructor is private, so this should fail
assert(not pcall(function() v.D() end))

-- DD shouldn't get a default constructor, so this should fail
assert(not pcall(function() v.DD() end))

-- AD shouldn't get a default constructor, so this should fail
assert(not pcall(function() v.AD() end))

-- Both of the arguments to E's constructor have default values,
-- so this should be fine.
local e = v.E()

-- EE should get a default constructor
local ee = v.EE()

-- EB should not get a default constructor (because B doesn't have one)
assert(not pcall(function() v.EB() end))

-- This should work fine
local f = v.F()
local g = v.G()
local gg = v.GG()

local v=require("constructor_copy")

local f1 = v.Foo1(3)
assert(f1 ~= nil)
local f11 = v.Foo1(f1)
assert(f11 ~= nil)
assert(f1.x == f11.x)

local f8 = v.Foo8()
assert(f8 ~= nil)
assert(not pcall(function() Foo8(f8) end))

local bi = v.Bari(5)
assert(bi ~= nil)
local bc = v.Bari(bi)
assert(bc ~= nil)
assert(bi.x == bc.x)

local bd = v.Bard(5)
assert(bd ~= nil)
assert(not pcall(function() Bard(bd) end))

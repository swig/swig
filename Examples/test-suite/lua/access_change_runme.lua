local v=require("access_change")

local baseInt = v.BaseInt()
assert(baseInt ~= nil)
assert(baseInt:PublicProtectedPublic1() == nil)
assert(baseInt:PublicProtectedPublic2() == nil)
assert(baseInt:PublicProtectedPublic3() == nil)
assert(baseInt:PublicProtectedPublic4() == nil)
-- Protected methods
assert(not pcall(function () baseInt:WasProtected1() end))
assert(not pcall(function () baseInt:WasProtected2() end))
assert(not pcall(function () baseInt:WasProtected3() end))
assert(not pcall(function () baseInt:WasProtected4() end))

local derivedInt = v.DerivedInt()
assert(derivedInt ~= nil)
-- Here there are public
assert(derivedInt:WasProtected1() == nil)
assert(derivedInt:WasProtected2() == nil)
assert(derivedInt:WasProtected3() == nil)
assert(derivedInt:WasProtected4() == nil)
-- inherite public from base
assert(derivedInt:PublicProtectedPublic1() == nil)
assert(derivedInt:PublicProtectedPublic2() == nil)
assert(derivedInt:PublicProtectedPublic3() == nil)
assert(derivedInt:PublicProtectedPublic4() == nil)

local bottomInt = v.BottomInt()
assert(bottomInt ~= nil)
-- All methods are public
assert(bottomInt:WasProtected1() == nil)
assert(bottomInt:WasProtected2() == nil)
assert(bottomInt:WasProtected3() == nil)
assert(bottomInt:WasProtected4() == nil)
assert(bottomInt:PublicProtectedPublic1() == nil)
assert(bottomInt:PublicProtectedPublic2() == nil)
assert(bottomInt:PublicProtectedPublic3() == nil)
assert(bottomInt:PublicProtectedPublic4() == nil)

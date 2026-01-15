require("import")                 -- the import fn
import("cpp11_shared_ptr_upcast") -- import lib

local s = cpp11_shared_ptr_upcast

-- Test single shared_ptr upcast (Derived -> Base)
assert(s.derived_num1(s.Derived(7)) == 7)
assert(s.base_num1(s.Derived(7)) == -1) -- Upcast works for single shared_ptr

-- Test with nil
assert(s.derived_num1(nil) == 999)
assert(s.base_num1(nil) == 999)

-- Test collections with matching types (no upcast needed)
local derivedList = s.DerivedList()
derivedList:push_back(s.Derived(7))
assert(s.derived_num2(derivedList) == 7)

local derivedMap = s.DerivedMap()
derivedMap:set(0, s.Derived(7))
assert(s.derived_num3(derivedMap) == 7)

local baseList = s.BaseList()
baseList:push_back(s.Base())
assert(s.base_num2(baseList) == -1)

local baseMap = s.BaseMap()
baseMap:set(0, s.Base())
assert(s.base_num3(baseMap) == -1)

-- Test collections with nil
local derivedListNil = s.DerivedList()
derivedListNil:push_back(nil)
assert(s.derived_num2(derivedListNil) == 999)

local derivedMapNil = s.DerivedMap()
derivedMapNil:set(0, nil)
assert(s.derived_num3(derivedMapNil) == 999)

local baseListNil = s.BaseList()
baseListNil:push_back(nil)
assert(s.base_num2(baseListNil) == 999)

local baseMapNil = s.BaseMap()
baseMapNil:set(0, nil)
assert(s.base_num3(baseMapNil) == 999)

-- Test overloaded functions with matching types
assert(s.derived_num(s.Derived(7)) == 7)
assert(s.base_num(s.Derived(7)) == -1)

local derivedList2 = s.DerivedList()
derivedList2:push_back(s.Derived(7))
assert(s.derived_num(derivedList2) == 7)

local derivedMap2 = s.DerivedMap()
derivedMap2:set(0, s.Derived(7))
assert(s.derived_num(derivedMap2) == 7)

-- ptr to shared_ptr tests (simpler cases only - collections of ptr to shared_ptr not yet supported)
assert(s.derived2_num1(s.Derived2(7)) == 7)
assert(s.base2_num1(s.Derived2(7)) == -1) -- Upcast works for pointer to shared_ptr

-- Test nil cases for ptr to shared_ptr
assert(s.derived2_num1(nil) == 888)
assert(s.base2_num1(nil) == 888)

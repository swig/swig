require("import")                   -- the import fn
import("cpp11_shared_ptr_overload") -- import lib

local s = cpp11_shared_ptr_overload

-- ref
local ret = s.UseA(s.MyType("123"))
assert(ret == "123 ref", "UseA fail:" .. ret)

ret = s.UseB(0, s.MyType("123"))
assert(ret == "123 ref", "UseB fail:" .. ret)

ret = s.UseC(0, s.MyType("123"), s.MyType("456"))
assert(ret == "123 ref", "UseC fail:" .. ret)

-- sharedptr
ret = s.UseX(s.MyType("123"))
assert(ret == "123 sharedptr", "UseX fail:" .. ret)

ret = s.UseY(0, s.MyType("123"))
assert(ret == "123 sharedptr", "UseY fail:" .. ret)

ret = s.UseZ(0, s.MyType("123"), s.MyType("456"))
assert(ret == "123 sharedptr", "UseZ fail:" .. ret)

-- Combo1-4
ret = s.Combo1(s.MyType("XXX"))
assert(ret == "XXXCombo1", "Combo1 fail:" .. ret)

ret = s.Combo2(s.MyType("XXX"))
assert(ret == "XXXCombo2", "Combo2 fail:" .. ret)

ret = s.Combo3(s.MyType("XXX"))
assert(ret == "XXXCombo3", "Combo3 fail:" .. ret)

ret = s.Combo4(s.MyType("XXX"))
assert(ret == "XXXCombo4", "Combo4 fail:" .. ret)

-- Combo5-7
ret = s.Combo5(s.MyType("XXX"))
assert(ret == "XXXCombo5", "Combo5 fail:" .. ret)

ret = s.Combo6(s.MyType("XXX"))
assert(ret == "XXXCombo6", "Combo6 fail:" .. ret)

ret = s.Combo7(s.MyType("XXX"))
assert(ret == "XXXCombo7", "Combo7 fail:" .. ret)

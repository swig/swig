local v=require("using_inherit")

-- Lua uses number for both float and integer
-- Lua can not differentiate, C/C++ must differentiate function names

local b = v.Bar()
assert(b:test(3) == 3, "Bar::test(int)")
-- assert(b:test(3.5) == 3.5, "Bar::test(double)")

b = v.Bar2()
assert(b:test(3) == 6, "Bar2::test(int)")
-- assert(b:test(3.5) == 7, "Bar2::test(double)")

b = v.Bar3()
assert(b:test(3) == 6, "Bar3::test(int)")
-- assert(b:test(3.5) == 7, "Bar3::test(double)")

b = v.Bar4()
assert(b:test(3) == 6, "Bar4::test(int)")
-- assert(b:test(3.5) == 7, "Bar4::test(double)")

b = v.Fred1()
assert(b:test(3) == 3, "Fred1::test(int)")
-- assert(b:test(3.5) == 7, "Fred1::test(double)")

b = v.Fred2()
assert(b:test(3.5) == 7, "Fred2::test(double)")

local v=require("using_composition")

local f = v.FooBar()
assert(f:blah(3) == 3, "FooBar::blah(int)")
-- Lua uses number for both float and integer
-- lua can not differentiate, C/C++ must differentiate function names
-- assert(f:blah(3.5) == 3.5, "FooBar::blah(double)")
assert(f:blah("hello") == "hello", "FooBar::blah(char *)")

f = v.FooBar2()
assert(f:blah(3) == 3, "FooBar2::blah(int)")
-- Lua uses number for both float and integer
-- Lua can not differentiate, C/C++ must differentiate function names
-- assert(f:blah(3.5) == 3.5, "FooBar2::blah(double)")
assert(f:blah("hello") == "hello", "FooBar2::blah(char *)")

f = v.FooBar3()
assert(f:blah(3) == 3, "FooBar3::blah(int)")
-- Lua uses number for both float and integer
-- Lua can not differentiate, C/C++ must differentiate function names
-- assert(f:blah(3.5) == 3.5, "FooBar3::blah(double)")
assert(f:blah("hello") == "hello", "FooBar3::blah(char *)")

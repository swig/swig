require("using_extend")

local f = using_extend.FooBar()
assert(f:blah(3) == 3, "blah(int)")
-- Lua uses number for both float and integer
-- Lua can not differentiate, C/C++ must differentiate function names
-- assert(f:blah(3.5) == 3.5, "blah(double)")
assert(f:blah("hello") == "hello", "blah(char *)")
assert(f:blah(3,4) == 7, "blah(int,int)")
-- Lua uses number for both float and integer
-- Lua can not differentiate, C/C++ must differentiate function names
-- assert(f:blah(3.5,7.5) == (3.5+7.5), "blah(double,double)")

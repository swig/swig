require("using_private")

local f = using_private.FooBar()
f.x = 3
assert(f:blah(4) == 4, "blah(int)")
assert(f:defaulted() == -1, "defaulted()")
assert(f:defaulted(222) == 222, "defaulted(hi)")

require("using_protected")

local f = using_protected.FooBar()
f.x = 3
assert(f:blah(4) == 4, "blah(int)")

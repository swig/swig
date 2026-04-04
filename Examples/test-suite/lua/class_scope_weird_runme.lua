require("class_scope_weird")

local f = class_scope_weird.Foo()
local g = class_scope_weird.Foo(3)
assert(f:bar(3) == 3)

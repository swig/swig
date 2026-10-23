require("typemap_documentation")

local f = typemap_documentation.Foo()
f.x = 55
local b = typemap_documentation.Bar()
b.y = 44

assert(55 == typemap_documentation.GrabVal(f))
assert(not pcall(function() typemap_documentation.GrabVal(b) end))
assert(55 == typemap_documentation.GrabValFooBar(f))

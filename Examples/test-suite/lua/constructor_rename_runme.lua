require("constructor_rename")

local f = constructor_rename.Foo()
assert(f ~= nil)
assert(swig_type(f) == "Foo *")
-- local r = constructor_rename.RenamedConstructor() TODO implement %rename

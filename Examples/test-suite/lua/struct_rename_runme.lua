require("struct_rename")

local b = struct_rename.Bar()
assert(swig_type(b) == "Foo *") -- type name is the original structure

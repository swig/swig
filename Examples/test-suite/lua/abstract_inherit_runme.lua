local v=require("abstract_inherit")

--[[  Shouldn't be able to instantiate any of these classes
      since none of them implements the pure virtual function
      declared in the base class (Foo). ]]
assert(not pcall(function () v.Foo() end))
assert(not pcall(function () v.Bar() end))

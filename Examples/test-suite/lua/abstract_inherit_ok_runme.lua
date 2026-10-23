local v=require("abstract_inherit_ok")

--[[ Shouldn't be able to instantiate Foo, because it declares
     a pure virtual function. ]]
assert(not pcall(function () v.Foo() end))

--[[ This one's OK since we cleared it with a %feature("notabstract")
     declaration in the interface file. ]]
local spam = v.Spam()
assert(spam ~= nil)
assert(spam:blah() == 0)

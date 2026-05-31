local v=require("abstract_signature")

--[[ Shouldn't be able to instantiate Abstract_foo, because it declares
     a pure virtual function. ]]
assert(not pcall(function ()
    local foo = v.abstract_foo()
    foo:meth(1)
end))


--[[ Shouldn't be able to instantiate an Abstract_bar either, because it doesn't
     implement the pure virtual function with the correct signature. ]]
assert(not pcall(function ()
    local foo = v.abstract_bar()
    foo:meth(1)
end))

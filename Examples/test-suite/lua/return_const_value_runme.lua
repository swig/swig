require("return_const_value")

local p = return_const_value.Foo_ptr.getPtr()
assert(p:getVal() == 17, "test1" .. p:getVal())
p = return_const_value.Foo_ptr.getConstPtr()
assert(p:getVal() == 17, "test2" .. p:getVal())

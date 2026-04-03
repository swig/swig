require("import")
require("extend_typedef_class")
etc=extend_typedef_class
catch_undef_globs() -- catch "undefined" global variables

function test_obj(obj, const)
  obj.membervar = const
  assert(obj:getvar() == const)
end

a1 = etc.AClass()
test_obj(a1,1)

b1 = etc.BClass()
test_obj(b1,2)

c1 = etc.CClass()
test_obj(c1,3)

d1 = etc.DClass()
test_obj(d1,4)

a2 = etc.AStruct()
test_obj(a2,5)

b2 = etc.BStruct()
test_obj(b2,6)

c2 = etc.CStruct()
test_obj(c2,7)

d2 = etc.DStruct()
test_obj(d2,8)

require("import")
require("extend_constructor_destructor")
ecd=extend_constructor_destructor
catch_undef_globs() -- catch "undefined" global variables

a1 = ecd.AStruct(101)
assert(a1.ivar == 101)
assert(ecd.globalVar == 101)

b1 = ecd.BStruct(201)
assert(b1.ivar == 201)
assert(ecd.globalVar == 201)

c1 = ecd.CStruct(301)
assert(c1.ivar == 301)
assert(ecd.globalVar == 301)

d1 = ecd.DStruct(401)
assert(d1.ivar == 401)
assert(ecd.globalVar == 401)

e1 = ecd.EStruct(501)
assert(e1.ivar == 501)
assert(ecd.globalVar == 501)

f1 = ecd.FStruct(601)
assert(f1.ivar == 601)
assert(ecd.globalVar == 601)

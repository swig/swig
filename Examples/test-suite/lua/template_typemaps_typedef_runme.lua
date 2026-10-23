local v=require("template_typemaps_typedef")

local m1 = v.MultimapIntA()
local dummy_pair = m1:make_dummy_pair()
local val = m1:typemap_test(dummy_pair).val
assert(val == 1234)

local m2 = v.MultimapAInt()
local dummy_pair = m2:make_dummy_pair()
val = m2:typemap_test(dummy_pair)
assert(val == 4321)
assert(v.typedef_test1(dummy_pair).val == 1234, "typedef_test1")
assert(v.typedef_test2(dummy_pair).val == 1234, "typedef_test2")
assert(v.typedef_test3(dummy_pair).val == 1234, "typedef_test3")
assert(v.typedef_test4(dummy_pair).val == 1234, "typedef_test4")
assert(v.typedef_test5(dummy_pair).val == 1234, "typedef_test5")
assert(v.typedef_test6(dummy_pair).val == 1234, "typedef_test6")

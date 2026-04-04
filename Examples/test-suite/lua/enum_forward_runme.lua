local v=require("enum_forward")

local f1 = v.get_enum1()
assert(f1 == 0) -- == AAA
assert(v.test_function1(f1) == f1)

local f2 = v.get_enum2()
assert(f2 == 0) -- == CCC
assert(v.test_function2(f2) == f2)

local f3 = v.get_enum3()
assert(f1 == v.EEE)
assert(v.test_function3(f3) == v.EEE)

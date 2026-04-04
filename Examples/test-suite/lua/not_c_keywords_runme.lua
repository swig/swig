local v=require("not_c_keywords")

local cs = v.ComplexStruct()
cs:init()
assert(cs.complex == 123, "complex not correct")
cs.complex = 456

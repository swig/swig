local v1=require("template_typedef_cplx2")
local v2=require("template_typedef_import")

-- this is OK
local s = v2.Sin()
s:get_base_value()
s:get_value()
s:get_arith_value()
v2.my_func_r(s)
v1.make_Multiplies_double_double_double_double(s, s)

local z = v2.CSin()
z:get_base_value()
z:get_value()
z:get_arith_value()
v2.my_func_c(z)
v1.make_Multiplies_complex_complex_complex_complex(z, z)

-- Here we fail
local d = v1.make_Identity_double()
v2.my_func_r(d)
local c = v1.make_Identity_complex()
v2.my_func_c(c)

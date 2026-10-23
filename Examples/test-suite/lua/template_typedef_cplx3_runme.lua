local v=require("template_typedef_cplx3")

-- this is OK
local s = v.Sin()
s:get_base_value()
s:get_value()
s:get_arith_value()
v.my_func_r(s)
v.make_Multiplies_double_double_double_double(s,s)

local z = v.CSin()
z:get_base_value()
z:get_value()
z:get_arith_value()
v.my_func_c(z)
v.make_Multiplies_complex_complex_complex_complex(z,z)

-- Here we fail
local d = v.make_Identity_double()
v.my_func_r(d)

local c = v.make_Identity_complex()
v.my_func_c(c)

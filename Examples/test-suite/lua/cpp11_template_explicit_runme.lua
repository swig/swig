local v=require("cpp11_template_explicit")

-- Call variants of the same templated function
local t1 = v.my_templated_function_int(1,1.0)
local t2 = v.my_templated_function_A(2,2.0)
local t3 = v.my_templated_function_TemperInt(3,3.0)

-- Check return types
assert(type(t1) == "number")
assert(swig_type(t2) == "A *")
assert(swig_type(t3) == "Temper< int > *")

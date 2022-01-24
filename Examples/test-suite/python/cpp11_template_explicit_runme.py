import cpp11_template_explicit

# Call variants of the same templated function
t1 = cpp11_template_explicit.my_templated_function_int      (1,1.0)
t2 = cpp11_template_explicit.my_templated_function_A        (2,2.0)
t3 = cpp11_template_explicit.my_templated_function_TemperInt(3,3.0)

# Check return types
assert isinstance(t1,int)
assert isinstance(t2,cpp11_template_explicit.A)
assert isinstance(t3,cpp11_template_explicit.TemperInt)

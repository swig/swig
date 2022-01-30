import cpp11_template_explicit

def swig_assert_isinstance(a, b):
	if not isinstance(a, b):
		raise RuntimeError(str(a) + " not an instance of " + str(b))

# Call variants of the same templated function
t1 = cpp11_template_explicit.my_templated_function_int      (1,1.0)
t2 = cpp11_template_explicit.my_templated_function_A        (2,2.0)
t3 = cpp11_template_explicit.my_templated_function_TemperInt(3,3.0)

# Check return types
swig_assert_isinstance(t1,int)
swig_assert_isinstance(t2,cpp11_template_explicit.A)
swig_assert_isinstance(t3,cpp11_template_explicit.TemperInt)

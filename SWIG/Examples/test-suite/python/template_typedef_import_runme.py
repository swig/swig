import string
from template_typedef_cplx2 import *
from template_typedef_import import *

#
# double case
#


d = make_Identity_double()
print d.get_base_value()
print d.get_value()
print d.get_arith_value()

print make_Multiplies_double_double_double_double(d,d)
print my_func_r(d)


c = make_Identity_double()
print c.get_base_value()
print c.get_value()
print c.get_arith_value()

print make_Multiplies_complex_complex_complex_complex(c,c)
print my_func_c(c)

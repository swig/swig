import string
from template_typedef_cplx2 import *
from template_typedef_import import *

#
# this is OK
#


s = Sin()
s.get_base_value()
s.get_value()
s.get_arith_value()
my_func_r(s)
make_Multiplies_double_double_double_double(s,s)

z = CSin()
z.get_base_value()
z.get_value()
z.get_arith_value()
my_func_c(z)
make_Multiplies_complex_complex_complex_complex(z,z)

#
# Here we fail
#
try:
  d = make_Identity_double()
  my_func_r(d)
except:
  print d, "is not a RFunction?, but yes it is!" 
  raise RuntimeError

try:
  c = make_Identity_double()
  my_func_c(c)
except:
  print c, "is not a CFunction?, but yes it is!" 
  raise RuntimeError
  




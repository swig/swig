import string
from template_typedef_cplx2 import *

#
# double case
#

try:
  d = make_Identity_double()
  a = d.this
except:
  print d, "is not an instance"
  raise RuntimeError

s = string.split('%s' % d)[1]
if string.find(s, 'ArithUnaryFunction') == -1:
  print d, "is not an ArithUnaryFunction"
  raise RuntimeError

try:
  e = make_Multiplies_double_double_double_double(d, d)
  a = e.this
except:
  print e, "is not an instance"
  raise RuntimeError

s = string.split('%s' % e)[1]
if string.find(s, 'ArithUnaryFunction') == -1:
  print e, "is not an ArithUnaryFunction"
  raise RuntimeError


#
# complex case
#

try:
  c = make_Identity_complex()
  a = c.this
except:
  print c, "is not an instance"
  raise RuntimeError

s = string.split('%s' % c)[1]
if string.find(s, 'ArithUnaryFunction') == -1:
  print c, "is not an ArithUnaryFunction"
  raise RuntimeError

try:
  f = make_Multiplies_complex_complex_complex_complex(c, c)
  a = f.this
except:
  print f, "is not an instance"
  raise RuntimeError

s = string.split('%s' % f)[1]
if string.find(s, 'ArithUnaryFunction') == -1:
  print f, "is not an ArithUnaryFunction"
  raise RuntimeError

#
# Mix case
#

try:
  g = make_Multiplies_double_double_complex_complex(d, c)
  a = g.this
except:
  print g, "is not an instance"
  raise RuntimeError

s = string.split('%s' % g)[1]
if string.find(s, 'ArithUnaryFunction') == -1:
  print g, "is not an ArithUnaryFunction"
  raise RuntimeError


try:
  h = make_Multiplies_complex_complex_double_double(c, d)
  a = h.this
except:
  print h, "is not an instance"
  raise RuntimeError

s = string.split('%s' % g)[1]
if string.find(s, 'ArithUnaryFunction') == -1:
  print g, "is not an ArithUnaryFunction"
  raise RuntimeError

try:
  a = g.get_value()
except:
  print g, "has not get_value() method"
  raise RuntimeError


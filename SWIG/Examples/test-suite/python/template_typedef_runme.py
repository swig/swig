import string
from template_typedef import *

#
# float case
#

try:
  d = make_Identity_float()
  a = d.this
except:
  print d, "is not an instance"
  raise RuntimeError

s = string.split('%s' % d)[1]
if string.find(s, 'ArithUnaryFunction') == -1:
  print d, "is not an ArithUnaryFunction"
  raise RuntimeError

try:
  e = make_Multiplies_float_float_float_float(d, d)
  a = e.this
except:
  print e, "is not an instance"
  raise RuntimeError

s = string.split('%s' % e)[1]
if string.find(s, 'ArithUnaryFunction') == -1:
  print e, "is not an ArithUnaryFunction"
  raise RuntimeError


#
# real case
#

try:
  c = make_Identity_real()
  a = c.this
except:
  print c, "is not an instance"
  raise RuntimeError

s = string.split('%s' % c)[1]
if string.find(s, 'ArithUnaryFunction') == -1:
  print c, "is not an ArithUnaryFunction"
  raise RuntimeError

try:
  f = make_Multiplies_real_real_real_real(c, c)
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
  g = make_Multiplies_float_float_real_real(d, c)
  a = g.this
except:
  print g, "is not an instance"
  raise RuntimeError

s = string.split('%s' % g)[1]
if string.find(s, 'ArithUnaryFunction') == -1:
  print g, "is not an ArithUnaryFunction"
  raise RuntimeError


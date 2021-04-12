from template_typedef_cplx2 import *

#
# double case
#

try:
    d = make_Identity_double()
    a = d.this
except:
    raise RuntimeError("{} is not an instance".format(d))

s = "%s" % d
if str.find(s, "ArithUnaryFunction") == -1:
    raise RuntimeError("{} is not an ArithUnaryFunction".format(d))

try:
    e = make_Multiplies_double_double_double_double(d, d)
    a = e.this
except:
    raise RuntimeError("{} is not an instance".format(e))

s = "%s" % e
if str.find(s, "ArithUnaryFunction") == -1:
    raise RuntimeError("{} is not an ArithUnaryFunction".format(e))


#
# complex case
#

try:
    c = make_Identity_complex()
    a = c.this
except:
    raise RuntimeError("{} is not an instance".format(c))

s = "%s" % c
if str.find(s, "ArithUnaryFunction") == -1:
    raise RuntimeError("{} is not an ArithUnaryFunction".format(c))

try:
    f = make_Multiplies_complex_complex_complex_complex(c, c)
    a = f.this
except:
    raise RuntimeError("{} is not an instance".format(f))

s = "%s" % f
if str.find(s, "ArithUnaryFunction") == -1:
    raise RuntimeError("{} is not an ArithUnaryFunction".format(f))

#
# Mix case
#

try:
    g = make_Multiplies_double_double_complex_complex(d, c)
    a = g.this
except:
    raise RuntimeError("{} is not an instance".format(g))

s = "%s" % g
if str.find(s, "ArithUnaryFunction") == -1:
    raise RuntimeError("{} is not an ArithUnaryFunction".format(g))


try:
    h = make_Multiplies_complex_complex_double_double(c, d)
    a = h.this
except:
    raise RuntimeError("{} is not an instance".format(h))

s = "%s" % h
if str.find(s, "ArithUnaryFunction") == -1:
    raise RuntimeError("{} is not an ArithUnaryFunction".format(h))

try:
    a = g.get_value()
except:
    raise RuntimeError("{}, has not get_value() method".format(g))

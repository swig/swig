from exception_order import *


a = A()

try:
  a.foo()
except E1,e:
  pass
except:
  raise RuntimeError, "bad exception order"

try:
  a.bar()
except E2,e:
  pass
except:
  raise RuntimeError, "bad exception order"

try:
  a.foobar()
except RuntimeError,e:
  if e.args[0] != "postcatch unknown":
    print "bad exception order", 
    raise RuntimeError, e.args


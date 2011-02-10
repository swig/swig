from exception_order import *


a = A()

try:
  a.foo()
# Throwing builtin classes as exceptions not supported
#except E1,e:
#  pass
except:
#  raise RuntimeError, "bad exception order"
  pass

try:
  a.bar()
# Throwing builtin classes as exceptions not supported
#except E2,e:
#  pass
except:
#  raise RuntimeError, "bad exception order"
  pass

try:
  a.foobar()
except RuntimeError,e:
  if e.args[0] != "postcatch unknown":
    print "bad exception order", 
    raise RuntimeError, e.args



try:
  a.barfoo(1)
# Throwing builtin classes as exceptions not supported
#except E1,e:
#  pass
except:
#  raise RuntimeError, "bad exception order"
  pass

try:
  a.barfoo(2)
# Throwing builtin classes as exceptions not supported
#except E2,e:
#  pass
except:
#  raise RuntimeError, "bad exception order"
  pass

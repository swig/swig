import exception_order


a = exception_order.A()

try:
  a.foo()
except RuntimeError,e:
  if e.args[0] != "E1":
    print "bad exception order", 
    raise RuntimeError, e.args

try:
  a.bar()
except RuntimeError,e:
  if e.args[0] != "E2":
    print "bad exception order", 
    raise RuntimeError, e.args

try:
  a.foobar()
except RuntimeError,e:
  if e.args[0] != "postcatch unknown":
    print "bad exception order", 
    raise RuntimeError, e.args


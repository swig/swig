import exception_order


a = exception_order.A()

try:
  a.foo()
except RuntimeError,e:
  if e.args[0] != "E":
    print "bad exception order", 
    raise RuntimeError, e.args


  

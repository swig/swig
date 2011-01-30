import python_nondynamic

aa = python_nondynamic.A()

aa.a = 1
aa.b = 2
try:
  aa.c = 2
  err = 0
except:
  err = 1

if not err:  
  raise RuntimeError, "A is not static"  


class B(python_nondynamic.A):
  c = 4
  def __init__(self):
    python_nondynamic.A.__init__(self)
    pass
  pass



bb = B()

# This is questionable.  Trying to set B.c?  That's not what it does.
# Should fail, I think, but it doesn't.
#bb.c = 3

try:
  bb.d = 2
  err = 0
except:
  err = 1

if not err:  
  raise RuntimeError, "B is not static"  
    
      
cc = python_nondynamic.C()
cc.d = 3

from li_boost_shared_ptr_bits import *

def check(nd):
  nd.i = 200
  i = nd.i

  try:
    nd.notexist = 100
    passed = 0
  except:
    passed = 1

  if not passed:
    raise "Test failed"

nd = NonDynamic()
check(nd)
b = boing(nd)
check(b)


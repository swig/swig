from static_member_overload import *

foo = Foo()

# TODO
# The current dispatcher is not able to handle both
# instance and static methods
if foo.sum(foo, 1, 2) != 3:
  raise RuntimeError('instance member failed')

if Foo.sum(1, 2, 3) != 6:
  raise RuntimeError('static member failed')

try:
  foo.sum(1, 2, 3)
  raise RuntimeError('instance member should have failed')
except:
  pass

try:
  Foo.sum(1, 2)
  raise RuntimeError('static member should have failed')
except:
  pass

import _profiletest
#import profiletest

a = _profiletest.new_A()
b = _profiletest.new_B()
for i in range(0,10000000):
  a = _profiletest.B_fn(b, a)

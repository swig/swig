from refcount import *
#
# very innocent example
#

a = A3()
b1 = B(a)
b2 = B.create(a)



if a.ref_count() != 3:
  print "This program will crash... now"



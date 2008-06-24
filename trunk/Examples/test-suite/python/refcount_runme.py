from refcount import *
#
# very innocent example
#

a = A3()
b1 = B(a)
b2 = B.create(a)



if a.ref_count() != 3:
  print "This program will crash... now"


rca = b2.get_rca()
b3 = B.create(rca)

if a.ref_count() != 5:
  print "This program will crash... now"


v = vector_A(2)
v[0] = a
v[1] = a

x = v[0]
del v





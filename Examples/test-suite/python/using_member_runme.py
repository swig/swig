from using_member import *

b = B()
assert b.get(int(1)) == 10
assert b.get(float(1)) == 20

bb = BB()
assert bb.greater(int(1)) == 0
assert bb.greater(float(1)) == 1
assert bb.great(True) == 2

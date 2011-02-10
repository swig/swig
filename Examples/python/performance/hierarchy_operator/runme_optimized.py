#!/usr/bin/env python

import Simple_optimized
import time

t1 = time.clock()
x = Simple_optimized.H()
for i in range(10000000) :
    x += i
t2 = time.clock()
print "Simple_optimized took %f seconds" % (t2 - t1)

#!/usr/bin/env python

import Simple_optimized
import time

t1 = time.clock()
for i in range(1000000) :
    x = Simple_optimized.MyClass()
    #x.func()
t2 = time.clock()
print "Simple_optimized took %f seconds" % (t2 - t1)

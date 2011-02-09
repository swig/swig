#!/usr/bin/env python

import Simple_baseline
import time

t1 = time.clock()
for i in range(1000000) :
    x = Simple_baseline.MyClass()
    #x.func()
t2 = time.clock()
print "Simple_baseline took %f seconds" % (t2 - t1)

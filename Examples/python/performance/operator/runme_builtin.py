#!/usr/bin/env python

import Simple_builtin
import time

t1 = time.clock()
x = Simple_builtin.MyClass()
for i in range(10000000) :
    x = x + i
t2 = time.clock()
print "Simple_builtin took %f seconds" % (t2 - t1)

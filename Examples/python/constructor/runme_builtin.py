#!/usr/bin/env python

import Simple_builtin
import time

t1 = time.clock()
for i in range(1000000) :
    x = Simple_builtin.MyClass()
    #x.func()
t2 = time.clock()
print "Simple_builtin took %f seconds" % (t2 - t1)

#!/home/sci/local/bin/python
#
# Python test script.   This also illustrates the use of get/set
# for C variables.

from example import *
print get_time()
print "My Variable = ", cvar.My_variable
for i in range(0,14):
    n = fact(i)
    print i, "factorial is ", n

for i in range(1,250):
    for j in range(1,250):
        n = mod(i,j)
        cvar.My_variable = cvar.My_variable + n

print "My_variable = ", cvar.My_variable













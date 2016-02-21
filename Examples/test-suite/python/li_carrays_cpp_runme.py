from li_carrays_cpp import *

d = doubleArray(10)

d[0] = 7
d[5] = d[0] + 3

if d[5] + d[0] != 17:
    raise RuntimeError

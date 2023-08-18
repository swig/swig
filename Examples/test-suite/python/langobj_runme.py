import sys
from langobj import *


x = 256*256+1
rx = sys.getrefcount(x)
v = identity(x)
rv = sys.getrefcount(v)
if v != x:
    raise RuntimeError

if rv - rx != 1:
    raise RuntimeError

import sys
from langobj import *


x = 256*256+1

# avoid an immortal object for the ref count check to always work such as when using no-gil
x += 1

rx = sys.getrefcount(x)
v = identity(x)
rv = sys.getrefcount(v)
if v != x:
    raise RuntimeError

if rv - rx != 1:
    raise RuntimeError

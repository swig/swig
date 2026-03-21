
from li_cdata import *

s = b"ABC\x00abc"
m = malloc(256)
memmove(m, s)
ss = cdata(m, 7)
if ss != b"ABC\x00abc":
    raise "failed"

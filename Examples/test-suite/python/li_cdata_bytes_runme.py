import sys

# cdata returns a bytes object; indexing it yields ints only on Python 3.
if sys.version_info[0] < 3:
  sys.exit(0)

from li_cdata_bytes import *

m = predefStr()
s = cdata(m, 0x200)
for i in range(0x100):
  if s[i] != i:
    msg = "Value " + str(s[i]) + " should be " + str(i) + " at index " + str(i)
    raise Exception(msg)
  if s[i + 0x100] != i:
    msg = "Value " + str(s[i + 0x100]) + " should be " + str(i) + " at index " + str(i + 0x100)
    raise Exception(msg)
s2 = b''
for i in range(0x100):
  d = 255 - i
  s2 += bytes([d])
s = s2 + s2
m2 = malloc(0x200)
memmove(m2, s)
if verifyBytes(m2) < 0:
  raise Exception("verifyBytes fail")
free(m2)

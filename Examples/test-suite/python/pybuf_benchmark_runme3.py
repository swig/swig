import pybuf
import time
k=1000000
n=7

t=time.time()
a = bytearray(b'hello world')
for i in range(k):
  pybuf.title1(a)
print("Time used by bytearray:",time.time()-t)

t=time.time()
b = 'hello world'
for i in range(k):
  pybuf.title2(b)
print("Time used by string:",time.time()-t)

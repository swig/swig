from disown import *

a = A()
b = B()

b.acquire(a)

if a.this.own():
    raise RuntimeError

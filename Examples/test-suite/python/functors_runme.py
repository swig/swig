from functors import *

a = Functor0(10)
b = Functor1(10)
c = Functor2(10)

if a()!=-10:
    raise RuntimeError("a failed")
if b(1)!=11:
    raise RuntimeError("b failed")
if c(1, 2)!=13:
    raise RuntimeError("c failed")

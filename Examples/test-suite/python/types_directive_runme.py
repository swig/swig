from types_directive import *

d1 = Time1(2001, 2, 3, 60)
newDate = add(d1, 7) # check that a Time1 instance is accepted where Date is expected
if newDate.day != 10:
  raise RuntimeError

d2 = Time2(1999, 8, 7, 60)
newDate = add(d2, 7) # check that a Time2 instance is accepted where Date is expected
if newDate.day != 14:
  raise RuntimeError


import attributetest

aa = attributetest.A(1,2,3)

if aa.a != 1:
  raise RuntimeError
aa.a = 3
if aa.a != 3:
  print aa.a
  raise RuntimeError


if aa.b != 2:
  raise RuntimeError
aa.b = 5
if aa.b != 5:
  raise RuntimeError



if aa.d != aa.b:
  raise RuntimeError

if aa.c != 3:
  raise RuntimeError
#aa.c = 5
#if aa.c != 3:
#  raise RuntimeError

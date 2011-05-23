from default_arg_values import *

d = Display()

if d.draw1() != 0:
  raise RuntimeError

if d.draw1(12) != 12:
  raise RuntimeError

p = createPtr(123);
if d.draw2() != 0:
  raise RuntimeError

if d.draw2(p) != 123:
  raise RuntimeError


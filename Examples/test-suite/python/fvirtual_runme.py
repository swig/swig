from fvirtual import *

sw = Switch()
n = Node()
i = sw.addChild(n);

if i != 2:
  raise RuntimeError, "addChild"


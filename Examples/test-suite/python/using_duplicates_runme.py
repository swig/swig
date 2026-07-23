from using_duplicates import *

from swig_test_utils import swig_check


u = UsedFromNS()
u.value = 42

c = ContainerUsedFromNS()
c.set(u)
swig_check(c.get().value, 42)
swig_check(c.item.value, 42)

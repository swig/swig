from li_boost_shared_ptr_template import *

b = BaseINTEGER()
d = DerivedINTEGER()
if b.bar() != 1:
    raise RuntimeError
if d.bar() != 2:
    raise RuntimeError
if bar_getter(b) != 1:
    raise RuntimeError
# Fix reverted in rev 12953
# if bar_getter(d) != 2:
#  raise RuntimeError

b = BaseDefaultInt()
d = DerivedDefaultInt()
d2 = DerivedDefaultInt2()
if b.bar2() != 3:
    raise RuntimeError
if d.bar2() != 4:
    raise RuntimeError
if d2.bar2() != 4:
    raise RuntimeError
if bar2_getter(b) != 3:
    raise RuntimeError
# Fix reverted in rev 12953
# if bar2_getter(d) != 4:
#  raise RuntimeError
# if bar2_getter(d2) != 4:
#  raise RuntimeError

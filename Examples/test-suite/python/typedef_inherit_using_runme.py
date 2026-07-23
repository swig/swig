from typedef_inherit_using import *

from swig_test_utils import swig_check


swig_check(Derived().m(), 11)
swig_check(Derived().n(7), 7)
swig_check(Derived2().m(), 11)
swig_check(UsesConv().toInt(), 42)

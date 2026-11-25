import sys
import weakref

from python_this_attribute import *
from swig_test_utils import swig_check

p = Point(3)
refs = sys.getrefcount(p.this)

swig_check(point_x(p), 3)
swig_check(point_x(weakref.proxy(p)), 3)
swig_check(sys.getrefcount(p.this), refs)


class Holder:
    def __init__(self, this):
        self.this = this


class FreshProxy:
    @property
    def this(self):
        # A new proxy object that nothing else refers to
        return global_point()


class FreshSwigObject:
    @property
    def this(self):
        return global_point().this


if not is_python_builtin():
    swig_check(point_x(Holder(Holder(p))), 3)
    swig_check(sys.getrefcount(p.this), refs)
    swig_check(point_x(FreshProxy()), 5)
    swig_check(point_x(FreshSwigObject()), 5)

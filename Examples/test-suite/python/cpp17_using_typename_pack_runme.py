from cpp17_using_typename_pack import *
from swig_test_utils import swig_check

c = CollectorInt()
swig_check(c.zero(), 0)   # value_type() == int() == 0
swig_check(c.echo(42), 42)

from cpp20_alias_template import *

from swig_test_utils import swig_check


# All four aliases - unconstrained, type-constraint in parm list,
# requires-clause and unseen-concept best effort - resolve to Box<int> in the
# type system and are wrapped as the single BoxInt class.
for factory, tag in [(make_plain,  "plain"),
                     (make_num,    "num"),
                     (make_req,    "req"),
                     (make_unseen, "unseen")]:
    b = factory(10)
    swig_check(b.get(), 10)
    b.set(42)
    swig_check(b.get(), 42)

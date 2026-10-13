from python_std_pair_castmode import *
from swig_test_utils import swig_check

c = Counted()
live = live_counted()

# A float for the int is a cast of higher rank than for the Counted, which left the pair made from the tuple undeleted
swig_check(take_pair((1.0, c)), 1)
swig_check(live_counted(), live)
swig_check(take_pair((1, c)), 1)
swig_check(live_counted(), live)

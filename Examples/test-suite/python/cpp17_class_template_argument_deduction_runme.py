from cpp17_class_template_argument_deduction import *

from swig_test_utils import swig_check

# The CTAD variables 'ov' and 'bx' are skipped (Warning 347); declarations alongside them wrap.
swig_check(unaffected(41), 42)

# The deduction guides emit nothing; a declaration following them still wraps.
swig_check(after_guides(40), 42)

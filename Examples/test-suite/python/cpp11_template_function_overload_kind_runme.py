from cpp11_template_function_overload_kind import *

from swig_test_utils import swig_check

swig_check(dflt_int(1), 1)
swig_check(dflt_int(1, 2), 2)
swig_check(value_default_int(1), 3)
swig_check(value_default_int_4(1), 4)
swig_check(DefaultHolderInt().convert_double(2.5), 2)

swig_check(pack_types(), 12)
swig_check(pack_values(), 23)

swig_check(mixed_type_first(), 32)
swig_check(mixed_value_first(), 43)

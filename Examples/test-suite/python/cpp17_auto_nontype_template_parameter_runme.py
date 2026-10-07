from cpp17_auto_nontype_template_parameter import *
from swig_test_utils import swig_check

swig_check(AutoParmInt().get(), 3)
swig_check(AutoParmInt().member, 3)
swig_check(AutoParmChar().get(), "c")
swig_check(AutoParmBool().get(), True)
swig_check(AutoParmUnsigned().get(), 7)
swig_check(auto_function_long(), 8)
swig_check(AutoParmInt.value, 3)
swig_check(AutoParmChar.value, "c")
swig_check(AutoParmBool.value, True)
swig_check(address_value(AddressParmPlain().get()), 4)
swig_check(address_value(AddressParmParen().get()), 5)

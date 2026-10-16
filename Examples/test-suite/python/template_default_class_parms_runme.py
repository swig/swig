from template_default_class_parms import *
from swig_test_utils import swig_check

second = Second()
second.value = 5
defaulted = DefaultedSecondInt()
defaulted.third = second
swig_check(defaulted.copy_third().value, 5)
swig_check(third_value(defaulted), 5)
defaulted.second = 10
swig_check(defaulted.second, 10)

all_defaulted = AllDefaultedInt()
all_defaulted.boxed.item = 7
swig_check(all_defaulted_item(all_defaulted), 7)

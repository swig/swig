from template_arg_names import *
from swig_test_utils import swig_check

second = Second()
second.value = 5

pair = PairSecond()
pair.first = second
pair.second = 10
swig_check(pair.copy_first().value, 5)
swig_check(pair.second, 10)
swig_check(first_value(pair), 5)
pair.link = pair
swig_check(pair.this_pair().link.copy_first().value, 5)

swig_check(pick_first_second(second, 10).value, 5)

first = First()
first.value = 2
swapped = PairSwap()
swapped.first = second
swapped.second = first
swig_check(swapped.copy_first().value, 5)
swig_check(swapped.second.value, 2)
swig_check(swapped_value(swapped), 7)

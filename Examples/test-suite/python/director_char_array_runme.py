import director_char_array
from swig_test_utils import swig_check

class Director(director_char_array.CharArrayDirector):
    def take_array(self, s):
        return len(s)
    def take_const_array(self, s):
        return len(s)
    def take_array_ref(self, s):
        return len(s)
    def take_const_array_ref(self, s):
        return len(s)
    def is_null_array(self, s):
        return 1 if s is None else 0

d = Director()
swig_check(d.call_take_array(), 4)
swig_check(d.call_take_const_array(), 4)
swig_check(d.call_take_array_ref(), 4)
swig_check(d.call_take_const_array_ref(), 4)
swig_check(d.call_take_array_short(), 2)
swig_check(d.call_take_array_ref_short(), 2)
swig_check(d.call_is_null_array(), 1)

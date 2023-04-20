from li_boost_shared_ptr_director import *

def swig_assert_equal(a, b):
	if a != b:
		raise RuntimeError(str(a) + " != " + str(b))

class Derived(Base):
    def __init__(self, flag):
        self.return_none = flag
        Base.__init__(self)

    def ret_c_shared_ptr(self):
        if self.return_none:
            return None
        else:
            return C()

    def ret_c_by_value(self):
        return C()

    def take_c_by_value(self,c):
        return c.get_m()

    def take_c_by_ref(self,c):
        return c.get_m()

    def take_c_by_pointer(self,c):
        if c:
            return c.get_m()
        else:
            return -2

    def take_c_by_pointer_ref(self,c):
        if c:
            return c.get_m()
        else:
            return -3

    def take_c_shared_ptr_by_value(self,c):
        if c:
            return c.get_m()
        else:
            return -4

    def take_c_shared_ptr_by_ref(self,c):
        if c:
            return c.get_m()
        else:
            return -5

    def take_c_shared_ptr_by_pointer(self,c):
        if c:
            return c.get_m()
        else:
            return -6

    def take_c_shared_ptr_by_pointer_ref(self,c):
        if c:
            return c.get_m()
        else:
            return -7

a = Derived(False)
b = Derived(True)

swig_assert_equal(call_ret_c_shared_ptr(a), 1)
swig_assert_equal(call_ret_c_shared_ptr(b), -1)
swig_assert_equal(call_ret_c_by_value(a),   1)

swig_assert_equal(call_take_c_by_value(a),                  5)
swig_assert_equal(call_take_c_by_ref(a),                    6)
swig_assert_equal(call_take_c_by_pointer(a),                7)
swig_assert_equal(call_take_c_by_pointer_ref(a),            8)
swig_assert_equal(call_take_c_shared_ptr_by_value(a),       9)
swig_assert_equal(call_take_c_shared_ptr_by_ref(a),         10)
swig_assert_equal(call_take_c_shared_ptr_by_pointer(a),     11)
swig_assert_equal(call_take_c_shared_ptr_by_pointer_ref(a), 12)

swig_assert_equal(call_take_c_by_pointer_with_null(a),                -2)
swig_assert_equal(call_take_c_by_pointer_ref_with_null(a),            -3)
swig_assert_equal(call_take_c_shared_ptr_by_value_with_null(a),       -4)
swig_assert_equal(call_take_c_shared_ptr_by_ref_with_null(a),         -5)
swig_assert_equal(call_take_c_shared_ptr_by_pointer_with_null(a),     -6)
swig_assert_equal(call_take_c_shared_ptr_by_pointer_ref_with_null(a), -7)

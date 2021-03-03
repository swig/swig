from cpp11_shared_ptr_upcast import *

# This is a port from the Ruby equivalent test and some tests ported from
# Examples/test-suite/ruby/cpp11_shared_ptr_upcast_runme.rb are not working and commented out with:
# not working:

def swig_assert_equal_simple(expected, got):
    if expected != got:
        raise RuntimeError("Expected: {}. Got: {}")

# non-overloaded
swig_assert_equal_simple(7, derived_num1(Derived(7)))
swig_assert_equal_simple(7, derived_num2([Derived(7)]))
swig_assert_equal_simple(7, derived_num3({0: Derived(7)}))

swig_assert_equal_simple(-1, base_num1(Derived(7)))
swig_assert_equal_simple(-1, base_num2([Derived(7)]))
swig_assert_equal_simple(-1, base_num3({0: Derived(7)}))

swig_assert_equal_simple(999, derived_num1(None))
# not working: swig_assert_equal_simple(999, derived_num2([None]))
# not working: swig_assert_equal_simple(999, derived_num3({0: None}))

swig_assert_equal_simple(999, base_num1(None))
# not working: swig_assert_equal_simple(999, base_num2([None]))
# not working: swig_assert_equal_simple(999, base_num3({0: None}))

# overloaded
swig_assert_equal_simple(7, derived_num(Derived(7)))
swig_assert_equal_simple(7, derived_num([Derived(7)]))
swig_assert_equal_simple(7, derived_num({0: Derived(7)}))

swig_assert_equal_simple(-1, base_num(Derived(7)))
swig_assert_equal_simple(-1, base_num([Derived(7)]))
swig_assert_equal_simple(-1, base_num({0: Derived(7)}))

# ptr to shared_ptr
swig_assert_equal_simple(7, derived2_num1(Derived2(7)))
swig_assert_equal_simple(7, derived2_num2([Derived2(7)]))
swig_assert_equal_simple(7, derived2_num3({0: Derived2(7)}))

swig_assert_equal_simple(-1, base2_num1(Derived2(7)))

# not working: try:
# not working:     # Upcast for pointers to shared_ptr in this generic framework has not been implemented
# not working:     swig_assert_equal_simple(-1, base2_num2([Derived2(7)]))
# not working:     raise RuntimeError, "Failed to catch TypeError"
# not working: except TypeError:
# not working:     pass
# not working: try:
# not working:     # Upcast for pointers to shared_ptr in this generic framework has not been implemented
# not working:     swig_assert_equal_simple(-1, base2_num3({0: Derived2(7)}))
# not working:     raise RuntimeError, "Failed to catch TypeError"
# not working: except TypeError:
# not working:     pass

swig_assert_equal_simple(888, derived2_num1(None))
swig_assert_equal_simple(999, derived2_num2([None])) # although 888 would be more consistent
swig_assert_equal_simple(999, derived2_num3({0: None})) # although 888 would be more consistent

swig_assert_equal_simple(888, base2_num1(None))
swig_assert_equal_simple(999, base2_num2([None])) # although 888 would be more consistent
swig_assert_equal_simple(999, base2_num3({0: None})) # although 888 would be more consistent

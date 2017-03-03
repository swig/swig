require "swig_assert"
require "cpp11_shared_ptr_const"

include Cpp11_shared_ptr_const

simple_assert_equal(7, foo_vec()[0].get_m )
simple_assert_equal(7, const_foo_vec()[0].get_m )

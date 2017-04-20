require "swig_assert"
require "cpp11_shared_ptr_const"

include Cpp11_shared_ptr_const

swig_assert_equal_simple(1,           foo( Foo.new(1) ).get_m )
swig_assert_equal_simple(7,     const_foo( Foo.new(7) ).get_m )
swig_assert_equal_simple(7,       foo_vec( Foo.new(7) )[0].get_m )
swig_assert_equal_simple(8, const_foo_vec( Foo.new(8) )[0].get_m )

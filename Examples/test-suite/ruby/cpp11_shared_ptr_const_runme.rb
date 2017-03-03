require "swig_assert"
require "cpp11_shared_ptr_const"

include Cpp11_shared_ptr_const

simple_assert_equal(1,           foo( Foo.new(1) ).get_m )
simple_assert_equal(7,     const_foo( Foo.new(7) ).get_m )
simple_assert_equal(7,       foo_vec( Foo.new(7) )[0].get_m )
simple_assert_equal(8, const_foo_vec( Foo.new(8) )[0].get_m )

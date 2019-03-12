#!/usr/bin/env ruby
#
# Runtime tests for ruby_alias_global_function.i
#

require 'swig_assert'
require 'ruby_alias_global_function'

expected_name = get_my_name

swig_assert(fullname == expected_name, msg: "nickname not working as expected")
swig_assert(nickname == expected_name, msg: "fullname not working as expected")

if method(:nickname).respond_to?(:original_name)
  swig_assert_equal_simple(method(:nickname).original_name, :get_my_name)
  swig_assert_equal_simple(method(:fullname).original_name, :get_my_name)
else
  swig_assert(method(:nickname) == method(:get_my_name), msg: "nickname is not an alias of get_my_name")
  swig_assert(method(:fullname) == method(:get_my_name), msg: "fullname is not an alias of get_my_name")
end

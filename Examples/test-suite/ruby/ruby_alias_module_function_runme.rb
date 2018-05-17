#!/usr/bin/env ruby
#
# Runtime tests for ruby_alias_module_function.i
#

require 'swig_assert'
require 'ruby_alias_module_function'

include Ruby_alias_module_function

expected_name = Ruby_alias_module_function.get_my_name

swig_assert(Ruby_alias_module_function.nickname == expected_name, msg: "nickname returned a different result than get_my_name")
swig_assert(Ruby_alias_module_function.fullname == expected_name, msg: "fullname returned a different result than get_my_name")

nickname_method =  Ruby_alias_module_function.method(:nickname)
fullname_method =  Ruby_alias_module_function.method(:fullname)

if nickname_method.respond_to?(:original_name)
  swig_assert_equal_simple(nickname_method.original_name, :get_my_name)
  swig_assert_equal_simple(fullname_method.original_name, :get_my_name)
else
  original_method = Ruby_alias_module_function.method(:get_my_name)
  swig_assert(nickname_method == original_method, msg: "nickname is not an alias of get_my_name")
  swig_assert(fullname_method == original_method, msg: "fullname is not an alias of get_my_name")
end

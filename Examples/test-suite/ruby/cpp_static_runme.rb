#!/usr/bin/env ruby
#
# This test implementation is derived from its Python counterpart.
#

require 'swig_assert'
require 'cpp_static'

Cpp_static::StaticFunctionTest.static_func()
Cpp_static::StaticFunctionTest.static_func_2(1)
Cpp_static::StaticFunctionTest.static_func_3(1, 2)

swig_assert_equal("Cpp_static::StaticMemberTest.static_int", "99", binding)
Cpp_static::StaticMemberTest.static_int = 10
swig_assert_equal("Cpp_static::StaticMemberTest.static_int", "10", binding)

swig_assert_equal("Cpp_static::StaticBase.statty", "11", binding)
swig_assert_equal("Cpp_static::StaticBase.grab_statty_base", "11", binding)
swig_assert_equal("Cpp_static::StaticDerived.statty", "111", binding)
swig_assert_equal("Cpp_static::StaticDerived.grab_statty_derived", "111", binding)
Cpp_static::StaticBase.statty = 22
Cpp_static::StaticDerived.statty = 222
swig_assert_equal("Cpp_static::StaticBase.statty", "22", binding)
swig_assert_equal("Cpp_static::StaticBase.grab_statty_base", "22", binding)
swig_assert_equal("Cpp_static::StaticDerived.statty", "222", binding)
swig_assert_equal("Cpp_static::StaticDerived.grab_statty_derived", "222", binding)

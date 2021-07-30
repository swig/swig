# -*- coding: utf-8 -*-
require 'swig_assert'
require 'li_std_wstring'

h = "h"
swig_assert_equal("Li_std_wstring.test_wcvalue(h)", "h", binding)

x = "abc"
swig_assert_equal("Li_std_wstring.test_ccvalue(x)", "x", binding)
swig_assert_equal("Li_std_wstring.test_cvalue(x)", "x", binding)

swig_assert_equal("Li_std_wstring.test_wchar_overload(x)", "x", binding)
swig_assert_equal("Li_std_wstring.test_wchar_overload()", "nil", binding)

Li_std_wstring.test_pointer(nil)
Li_std_wstring.test_const_pointer(nil)

begin
  Li_std_wstring.test_value(nil)
  raise RuntimeError, "NULL check failed"
rescue TypeError => e
end

begin
  Li_std_wstring.test_reference(nil)
  raise RuntimeError, "NULL check failed"
rescue ArgumentError => e
  swig_assert_simple(e.message.include? "invalid null reference")
end
begin
  Li_std_wstring.test_const_reference(nil)
  raise RuntimeError, "NULL check failed"
rescue ArgumentError => e
  swig_assert_simple(e.message.include? "invalid null reference")
end

x = "hello"
swig_assert_equal("Li_std_wstring.test_const_reference(x)", "x", binding)

s = "abc"
swig_assert("Li_std_wstring.test_equal_abc(s)", binding)

begin
  Li_std_wstring.test_throw
rescue RuntimeError => e
  swig_assert_equal("e.message", "'throwing test_throw'", binding)
end

x = "abc\0def"
swig_assert_equal("Li_std_wstring.test_value(x)", "x", binding)
swig_assert_equal("Li_std_wstring.test_ccvalue(x)", '"abc"', binding)
swig_assert_equal("Li_std_wstring.test_wchar_overload(x)", '"abc"', binding)

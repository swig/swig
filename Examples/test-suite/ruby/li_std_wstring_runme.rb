# -*- coding: utf-8 -*-
require 'swig_assert'
require 'li_std_wstring'

x = "abc"
swig_assert_equal("Li_std_wstring.test_wchar_overload(x)", "x", binding)
swig_assert_equal("Li_std_wstring.test_ccvalue(x)", "x", binding)
swig_assert_equal("Li_std_wstring.test_value(Li_std_wstring::Wstring.new(x))", "x", binding)

swig_assert_equal("Li_std_wstring.test_wchar_overload()", "nil", binding)

swig_assert_equal("Li_std_wstring.test_pointer(Li_std_wstring::Wstring.new(x))", "nil", binding)
swig_assert_equal("Li_std_wstring.test_const_pointer(Li_std_wstring::Wstring.new(x))", "nil", binding)
swig_assert_equal("Li_std_wstring.test_const_pointer(Li_std_wstring::Wstring.new(x))", "nil", binding)
swig_assert_equal("Li_std_wstring.test_reference(Li_std_wstring::Wstring.new(x))", "nil", binding)

x = "y"
swig_assert_equal("Li_std_wstring.test_value(x)", "x", binding)
a = Li_std_wstring::A.new(x)
swig_assert_equal("Li_std_wstring.test_value(a)", "x", binding)

x = "hello"
swig_assert_equal("Li_std_wstring.test_const_reference(x)", "x", binding)


swig_assert_equal("Li_std_wstring.test_pointer_out", "'x'", binding)
swig_assert_equal("Li_std_wstring.test_const_pointer_out", "'x'", binding)
swig_assert_equal("Li_std_wstring.test_reference_out()", "'x'", binding)

s = "abc"
swig_assert("Li_std_wstring.test_equal_abc(s)", binding)

begin
  Li_std_wstring.test_throw
rescue RuntimeError => e
  swig_assert_equal("e.message", "'x'", binding)
end

x = "abc\0def"
swig_assert_equal("Li_std_wstring.test_value(x)", "x", binding)
swig_assert_equal("Li_std_wstring.test_ccvalue(x)", '"abc"', binding)
swig_assert_equal("Li_std_wstring.test_wchar_overload(x)", '"abc"', binding)

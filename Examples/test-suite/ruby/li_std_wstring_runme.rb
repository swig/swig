# -*- coding: utf-8 -*-
require 'swig_assert'
require 'li_std_wstring'

x = "h"

swig_assert_equal("Li_std_wstring.test_value(x)", "x", binding)


x = "abc"

swig_assert_equal("Li_std_wstring.test_value(x)", "x", binding)

x = "hello"

swig_assert_equal("Li_std_wstring.test_const_reference(x)", "x", binding)

a = Li_std_wstring::A.new(x)

swig_assert_equal("Li_std_wstring.test_value(a)", "x", binding)

swig_assert_equal("Li_std_wstring.test_value(x)", "x", binding)

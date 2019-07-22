# -*- coding: utf-8 -*-
require 'swig_assert'
require 'li_std_wstring_inherit'
x = "abc"
swig_assert_equal("Li_std_wstring_inherit.test_value(Li_std_wstring_inherit::Wstring.new(x))", "x", binding)


x = "y"
swig_assert_equal("Li_std_wstring_inherit.test_value(x)", "x", binding)
a = Li_std_wstring_inherit::A.new(x)
swig_assert_equal("Li_std_wstring_inherit.test_value(a)", "x", binding)


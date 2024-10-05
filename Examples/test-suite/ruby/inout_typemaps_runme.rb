#!/usr/bin/env ruby
#
# Put description here
#
#
#
#
#

require 'swig_assert'

require 'inout_typemaps'

include Inout_typemaps

swig_assert_equal_simple(AddOne1(1), 2)

a = AddOne3(10, 20, 30)
swig_assert_equal_simple(a[0], 11)
swig_assert_equal_simple(a[1], 21)
swig_assert_equal_simple(a[2], 31)

a = AddOne1p([10, 20])
swig_assert_equal_simple(a[0], 11)
swig_assert_equal_simple(a[1], 21)

a = AddOne2p([10, 20], 30)
swig_assert_equal_simple(a[0][0], 11)
swig_assert_equal_simple(a[0][1], 21)
swig_assert_equal_simple(a[1], 31)

a = AddOne3p(10, [20, 30], 40)
swig_assert_equal_simple(a[0], 11)
swig_assert_equal_simple(a[1][0], 21)
swig_assert_equal_simple(a[1][1], 31)
swig_assert_equal_simple(a[2], 41)

ret, out = NonVoidOut(-42)
swig_assert_equal_simple(ret, nil)
swig_assert_equal_simple(out, 0)

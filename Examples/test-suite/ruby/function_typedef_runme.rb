#!/usr/bin/env ruby
#
# Tests for function_typedef.i
#
#

require 'swig_assert'
require 'function_typedef'
include Function_typedef

addfunc = Function_typedef.addfunc
swig_assert_equal(do_binop1(addfunc, 11, 22), 33, 'do_binop1')
swig_assert_equal(do_binop2(addfunc, 17, 51), 68, 'do_binop2')
swig_assert_equal(do_binop3(addfunc, 32, 47), 79, 'do_binop3')

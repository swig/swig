#!/usr/bin/env ruby
#
# This test implementation is directly derived from its Python counterpart.
#

require 'swig_assert'
require 'constant_directive'

swig_assert("Constant_directive::TYPE1_CONSTANT1.is_a?(Constant_directive::Type1)", binding)
swig_assert("Constant_directive::getType1Instance().is_a?(Constant_directive::Type1)", binding)

swig_assert_equal('Constant_directive::TYPE1_CONSTANT1.val', '1', binding)
swig_assert_equal('Constant_directive::TYPE1_CONSTANT2.val', '2', binding)
swig_assert_equal('Constant_directive::TYPE1_CONSTANT3.val', '3', binding)
swig_assert_equal('Constant_directive::TYPE1CONST_CONSTANT1.val', '1', binding)
swig_assert_equal('Constant_directive::TYPE1CPTR_CONSTANT1.val', '1', binding)

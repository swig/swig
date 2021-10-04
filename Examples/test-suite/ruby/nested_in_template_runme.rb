#!/usr/bin/env ruby
#
# This test implementation is directly derived from its Python counterpart.
#

require 'swig_assert'
require 'nested_in_template'


cd = Nested_in_template::ConcreteDerived.new(88)
swig_assert_equal('cd.m_value', '88', binding, 'ConcreteDerived not created correctly')

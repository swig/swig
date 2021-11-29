#!/usr/bin/env ruby
#
# This test implementation is derived from its Java counterpart.
#

require 'swig_assert'
require 'nested_workaround'

begin
  inner = Nested_workaround::Inner.new(5)
  outer = Nested_workaround::Outer.new
  newInner = outer.doubleInnerValue(inner)
  swig_assert_equal("newInner.getValue", "10", binding)
end

begin
  outer = Nested_workaround::Outer.new
  inner = outer.createInner(3)
  newInner = outer.doubleInnerValue(inner)
  swig_assert_equal("outer.getInnerValue(newInner)", "6", binding)
end

#!/usr/bin/env ruby
#
# Check the availability of expected classes and their member variables.
#

require 'swig_assert'
require 'nested_scope_flat'

Nested_scope_flat::Global_.new
Nested_scope_flat::Outer1.new
nested2 = Nested_scope_flat::Nested2.new
nested2.data = 42
swig_assert_equal("nested2.data", "42", binding)
Nested_scope_flat::Klass.new

Nested_scope_flat::Abstract_int
cannot_instantiate = false
begin
  Nested_scope_flat::Abstract_int.new
rescue TypeError
  cannot_instantiate = true
end
swig_assert_simple(cannot_instantiate)

Nested_scope_flat::Real.new.Method()

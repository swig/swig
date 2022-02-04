#!/usr/bin/env ruby
#
# Regression tests for Ruby naming bugs
#

require 'swig_assert'

require 'ruby_naming_bugs'

# Prior to SWIG 4.1.0 the "Cool_" here was overzealously removed
# while trying to remove a class name prefix, so this method would be
# named "somethingFast" in Ruby instead.
c = Ruby_naming_bugs::Cool.new()
if c.somethingCool_Fast != 42
  raise RuntimeError, "Incorrect value for somethingCool_Fast"
end

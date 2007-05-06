#!/usr/bin/env ruby
#
# Put description here
#
# 
# 
# 
#

require 'swig_assert'

require 'using_inherit'

include Using_inherit

b = Bar.new
if b.test(3) != 3
  raise RuntimeError,"test(int)"
end

if b.test(3.5) != 3.5
  raise RuntimeError, "test(double)"
end


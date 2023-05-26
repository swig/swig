#!/usr/bin/env ruby
#
# Put description here
#
# 
# 
# 
#

require 'swig_assert'

require 'cpp17_director_string_view'

class B < Cpp17_director_string_view::A

 def initialize(some_string)
  super(some_string)
 end
end


b = B.new("hello")
b.get_first
b.get(0)

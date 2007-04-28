#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'director_string'

class B < Director_string::A

 def initialize(some_string)
  super(some_string)
 end
end


b = B.new("hello")
b.get_first
b.get(0)

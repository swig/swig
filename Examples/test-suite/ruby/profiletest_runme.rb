#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'profiletest'

a = Profiletest::A.new()
b = Profiletest::B.new()

for i in 0...1000000
  a = b.fn(a)
end


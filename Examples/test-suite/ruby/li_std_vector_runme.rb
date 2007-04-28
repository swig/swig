#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'li_std_vector'

include Li_std_vector

iv = IntVector.new(4)
0.upto(3) { |i| iv[i] = i }

x = average(iv)
y = average([1, 2, 3, 4])

a = half([10, 10.5, 11, 11.5])

dv = DoubleVector.new(10)
0.upto(9) { |i| dv[i] = i/2.0 }

halve_in_place(dv)


#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'friends'


a = Friends::A.new(2)

raise RuntimeError if Friends::get_val1(a) != 2
raise RuntimeError if Friends::get_val2(a) != 4
raise RuntimeError if Friends::get_val3(a) != 6

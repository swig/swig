#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'overload_extend'

f = Overload_extend::Foo.new

raise RuntimeError if f.test(3) != 1
raise RuntimeError if f.test("hello") != 2
raise RuntimeError if f.test(3.5,2.5) != 6


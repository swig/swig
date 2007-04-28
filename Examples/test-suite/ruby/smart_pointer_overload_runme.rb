#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'smart_pointer_overload'

include Smart_pointer_overload

f = Foo.new
b = Bar.new(f)


raise RuntimeError if f.test(3) != 1
raise RuntimeError if f.test(3.5) != 2
raise RuntimeError if f.test("hello") != 3

raise RuntimeError if b.test(3) != 1
raise RuntimeError if b.test(3.5) != 2
raise RuntimeError if b.test("hello") != 3


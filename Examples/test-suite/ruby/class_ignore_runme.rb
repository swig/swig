#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'class_ignore'

a = Class_ignore::Bar.new

# Even though we didn't wrap the Foo class, this call
# to do_blah() should succeed.

if Class_ignore.do_blah(a) != "Bar::blah"
  raise RuntimeError
end

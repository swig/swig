#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'using_composition'

include Using_composition

f = FooBar.new
if f.blah(3) != 3
  raise RuntimeError,"blah(int)"
end

if f.blah(3.5) != 3.5
  raise RuntimeError,"blah(double)"
end

if f.blah("hello") != "hello"
  raise RuntimeError,"blah(char *)"
end


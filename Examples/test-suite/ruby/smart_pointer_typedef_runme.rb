#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'smart_pointer_typedef'

include Smart_pointer_typedef

f = Foo.new
b = Bar.new(f)

b.x = 3
raise RuntimeError if b.getx() != 3

fp = b.__deref__()
fp.x = 4
raise RuntimeError if fp.getx() != 4

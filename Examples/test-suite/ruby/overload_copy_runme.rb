#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'overload_copy'

include Overload_copy

f = Foo.new
g = Foo.new(f)

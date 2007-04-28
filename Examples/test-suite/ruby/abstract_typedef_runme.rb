#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'abstract_typedef'

include Abstract_typedef

e = Engine.new
a = A.new

swig_assert( a.write(e), 'for a.write(e)' )


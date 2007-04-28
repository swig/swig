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

raise RuntimeError if a.write(e) != true


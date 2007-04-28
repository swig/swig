#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'overload_template'

f = Overload_template.foo()

a = Overload_template.max(3,4)
b = Overload_template.max(3.4,5.2)

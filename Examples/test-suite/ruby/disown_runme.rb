#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'disown'

include Disown


a = A.new
b = B.new
b.acquire(a)


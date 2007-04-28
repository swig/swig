#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

# This is the import runtime testcase.

require 'imports_a'
require 'imports_b'

x = Imports_b::B.new

x.hello


#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'
require 'abstract_virtual'

include Abstract_virtual

swig_assert('d = D.new')
swig_assert('e = E.new')

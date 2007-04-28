#!/usr/bin/env ruby
#
# Put script description here.
#
# Author::    gga
# Copyright:: 2007
# License::   Ruby
#

require 'swig_assert'
require 'abstract_access'

include Abstract_access

begin
  a = A.new
rescue TypeError
  swig_assert(true, 'A.new')
end

begin
  b = B.new
rescue TypeError
  swig_assert(true, 'B.new')
end

begin
  c = C.new
rescue TypeError
  swig_assert(true, 'C.new')
end

swig_assert( 'D.new' )


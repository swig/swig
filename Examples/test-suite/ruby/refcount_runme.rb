#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'refcount'


a = Refcount::A3.new;
b1 = Refcount::B.new a;
b2 = Refcount::B.new a;

if a.ref_count() != 3 
  print "This program will crash... now\n"
end

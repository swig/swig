#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'director_frob'

foo = Director_frob::Bravo.new;
s = foo.abs_method;

raise RuntimeError if s != "Bravo::abs_method()"

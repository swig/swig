#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'typemap_namespace'

include Typemap_namespace

raise RuntimeError if test1("hello") != "hello"

raise RuntimeError if test2("hello") != "hello"

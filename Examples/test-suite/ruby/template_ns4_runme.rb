#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'template_ns4'

d = Template_ns4.make_Class_DD()
raise RuntimeError if d.test() != "test"

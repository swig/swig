#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'template_extend1'

a = Template_extend1::LBaz.new
b = Template_extend1::DBaz.new

raise RuntimeError unless a.foo() == "lBaz::foo"
raise RuntimeError unless b.foo() == "dBaz::foo"


#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'template_rename'

i = Template_rename::IFoo.new
d = Template_rename::DFoo.new

a = i.blah_test(4)
b = i.spam_test(5)
c = i.groki_test(6)

x = d.blah_test(7)
y = d.spam(8)
z = d.grok_test(9)

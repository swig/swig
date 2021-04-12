#!/usr/bin/env ruby
#
# This test implementation is directly derived from its Java counterpart.
#

require 'swig_assert'
require 'namespace_forward_declaration'

xxx = Namespace_forward_declaration::XXX.new
Namespace_forward_declaration.testXXX1(xxx)
Namespace_forward_declaration.testXXX2(xxx)
Namespace_forward_declaration.testXXX3(xxx)
yyy = Namespace_forward_declaration::YYY.new
Namespace_forward_declaration.testYYY1(yyy)
Namespace_forward_declaration.testYYY2(yyy)
Namespace_forward_declaration.testYYY3(yyy)

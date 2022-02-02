#!/usr/bin/env ruby
#
# This test implementation is directly derived from its Java counterpart.
#

require 'swig_assert'
require 'namespace_chase'

s1a = Namespace_chase::Struct1A.new
s1b = Namespace_chase::Struct1B.new
s1c = Namespace_chase::Struct1C.new

Namespace_chase.sss3a(s1a, s1b, s1c)
Namespace_chase.sss3b(s1a, s1b, s1c)

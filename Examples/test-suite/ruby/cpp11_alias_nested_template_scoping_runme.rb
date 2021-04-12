#!/usr/bin/env ruby
#
# This test implementation is directly derived from its Java counterpart.
#

require 'swig_assert'
require 'cpp11_alias_nested_template_scoping'

ys = Cpp11_alias_nested_template_scoping::Yshort.new
val = ys.create1
val = ys.create2
val = ys.create3
val = ys.create4
val = ys.create5
val = ys.create6
val = ys.create7

val = ys.create13

val = ys.create15
val = ys.create16
val = ys.create17


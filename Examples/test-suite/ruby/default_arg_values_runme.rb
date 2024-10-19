#!/usr/bin/env ruby

require 'swig_assert'

require 'default_arg_values'

d = Default_arg_values::Display.new

raise RuntimeError if d.draw1() != 0

raise RuntimeError if d.draw1(12) != 12

p = Default_arg_values::createPtr(123)
raise RuntimeError if d.draw2() != 0

raise RuntimeError if d.draw2(p) != 123

raise RuntimeError if d.draw3() != 0

raise RuntimeError unless d.bool0() === false

raise RuntimeError unless d.bool1() === true

raise RuntimeError unless d.mybool0() === false

raise RuntimeError unless d.mybool1() === true

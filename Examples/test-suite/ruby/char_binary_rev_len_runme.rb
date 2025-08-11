#!/usr/bin/env ruby
#
# Put description here
#

require 'swig_assert'
require 'char_binary_rev_len'

include Char_binary_rev_len

t = Test.new
str = 'hile'
swig_assert(t.strlen(str) == 4, binding, 'bad multi-arg typemap 1')
swig_assert(t.strlen("hil\000") == 4, binding, 'bad multi-arg typemap 2')

t2 = Test.new(str)
swig_assert(t2.getisize() == 4, binding, 'bad multi-arg typemap 3')
swig_assert(t2.strlen("hil\000a") == 5, binding, 'bad multi-arg typemap 4')

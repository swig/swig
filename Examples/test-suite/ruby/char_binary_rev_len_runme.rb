#!/usr/bin/env ruby
#
# Put description here
#

require 'swig_assert'
require 'char_binary_rev_len'

include Char_binary_rev_len

t = Test.new
str = 'hile'
swig_assert(t.strlen(str) == 4, binding, 'bad multi-arg typemap')
swig_assert(t.strlen("hil\000") == 4, binding, 'bad multi-arg typemap')

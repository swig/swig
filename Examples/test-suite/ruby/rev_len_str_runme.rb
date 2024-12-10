#!/usr/bin/env ruby
#
# Put description here
#

require 'swig_assert'
require 'rev_len_str'

include Rev_len_str

t = Test.new
str = 'hile'
swig_assert(t.strlen(str) == 4, binding, 'bad multi-arg typemap')
swig_assert(t.strlen("hil\000") == 4, binding, 'bad multi-arg typemap')

#!/usr/bin/env ruby
#
# Put description here
#
# 
# 
# 
#

require 'swig_assert'

require 'li_std_pair'
include Li_std_pair

swig_assert_each_line(<<'EOF', binding)
val = ValuePair.new
val.first = 'sd'
val.second = [5,4,3]
EOF

#!/usr/bin/env ruby

require 'swig_assert'

require 'li_std_tuple'
include Li_std_tuple

swig_assert_each_line(<<'EOF', binding)
sum_pair_values([3, 4.5]) == 7.5
r = make_int_double(10, 20.5)
r.instance_of?(Array)
r.size == 2
r[0] == 10
r[1] == 20.5
r3 = pass_tuples([1, 2.5], [10, 20.0])
r3.instance_of?(Array)
r3[0] == 11
r3[1] == 22.5
EOF

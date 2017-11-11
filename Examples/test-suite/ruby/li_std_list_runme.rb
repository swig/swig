require 'swig_assert'

require 'li_std_list'

include Li_std_list

x = DoubleList.new([1,2,3])
swig_assert_equal("[1.0]", "x.find_all{|e| e == 1 }", binding)

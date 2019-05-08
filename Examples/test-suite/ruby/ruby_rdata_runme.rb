require 'swig_assert'
require 'ruby_rdata'

include Ruby_rdata

swig_assert_equal_simple(1, take_proc_or_cpp_obj_and_ret_1(Proc.new{}))
swig_assert_equal_simple(1, take_proc_or_cpp_obj_and_ret_1(C.new))

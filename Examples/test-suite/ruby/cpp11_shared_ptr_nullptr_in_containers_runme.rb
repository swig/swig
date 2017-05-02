require "cpp11_shared_ptr_nullptr_in_containers"

include Cpp11_shared_ptr_nullptr_in_containers

a = ret_vec_c_shared_ptr()
raise unless a[0].get_m == 0
raise unless a[1]       == nil
raise unless a[2].get_m == 2

a = ret_arg_vec([C.new(7), nil, C.new(9)])
raise unless a[0].get_m == 7
raise unless a[1]       == nil
raise unless a[2].get_m == 9

raise unless is_last_null([C.new(7), C.new(8), nil])
raise if is_last_null([C.new(7), C.new(8)])

require "cpp11_shared_ptr_of_std_containers"

include Cpp11_shared_ptr_of_std_containers


a = StringVector.new
a.push("abc")
a[0] = "xyz"
raise unless a[0] == "xyz"

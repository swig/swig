local v=require("li_cpointer_cpp")

local p = v.new_intp()
assert(v.intp_value(p) == 0, "not initialized")
v.intp_assign(p, 3)
assert(v.intp_value(p) == 3)
v.delete_intp(p)

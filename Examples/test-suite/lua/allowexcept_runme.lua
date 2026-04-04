local v=require("allowexcept")

assert(v.global_variable == nil)
assert(v.Foo.static_member_variable == nil)

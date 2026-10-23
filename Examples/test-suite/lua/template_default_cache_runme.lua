local v=require("template_default_cache")

local ap = v.get_mp_a()
local bp = v.get_mp_b()
assert(swig_type(ap) == "ns_a::ModelPtr *|ns_a::iface1::ModelPtr *|d::d< ns_a::iface1::Model > *")
assert(swig_type(bp) == "ns_b::iface1::ModelPtr *|d::d< ns_b::iface1::Model > *")

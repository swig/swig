local v=require("template_using_directive_typedef")

local vo = v.Vector_Obj()

local h = v.Holder()
h:holder_use1(vo, vo, vo)
h:holder_use2(vo, vo, vo)
h:holder_use3(vo, vo, vo)

v.tns_holder_use(vo, vo)
v.tns_use(vo, vo, vo)
v.global_holder_use(vo)
v.global_use(vo, vo, vo)
v.ns1_holder_use(vo)
v.ns2_holder_use(vo, vo, vo, vo)

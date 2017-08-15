import template_using_directive_typedef

vo = template_using_directive_typedef.Vector_Obj();

h = template_using_directive_typedef.Holder();
h.holder_use1(vo, vo, vo);
h.holder_use2(vo, vo, vo);
h.holder_use3(vo, vo, vo);

template_using_directive_typedef.tns_holder_use(vo, vo);
template_using_directive_typedef.tns_use(vo, vo, vo);
template_using_directive_typedef.global_holder_use(vo);
template_using_directive_typedef.global_use(vo, vo, vo);
template_using_directive_typedef.ns1_holder_use(vo);
template_using_directive_typedef.ns2_holder_use(vo, vo, vo, vo);

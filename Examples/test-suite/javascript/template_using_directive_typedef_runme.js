var template_using_directive_typedef = require("template_using_directive_typedef")

var vo = new template_using_directive_typedef.Vector_Obj();

var h = new template_using_directive_typedef.Holder();
/* await */(h.holder_use1(vo, vo, vo));
/* await */(h.holder_use2(vo, vo, vo));
/* await */(h.holder_use3(vo, vo, vo));

/* await */(template_using_directive_typedef.tns_holder_use(vo, vo));
/* await */(template_using_directive_typedef.tns_use(vo, vo, vo));
/* await */(template_using_directive_typedef.global_holder_use(vo));
/* await */(template_using_directive_typedef.global_use(vo, vo, vo));
/* await */(template_using_directive_typedef.ns1_holder_use(vo));
/* await */(template_using_directive_typedef.ns2_holder_use(vo, vo, vo, vo));

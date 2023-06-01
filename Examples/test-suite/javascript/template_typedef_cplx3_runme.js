var template_typedef_cplx3 = require("template_typedef_cplx3");

//
// this is OK
//


s = new template_typedef_cplx3.Sin();
s.get_base_value();
s.get_value();
s.get_arith_value();
template_typedef_cplx3.my_func_r(s);
template_typedef_cplx3.make_Multiplies_double_double_double_double(s, s);

//
// Here we fail
//
d = template_typedef_cplx3.make_Identity_double();
template_typedef_cplx3.my_func_r(d);

var template_typedef_cplx4 = require("template_typedef_cplx4");

//
// this is OK
//


var s = new template_typedef_cplx4.Sin();
/* await */(s.get_base_value());
/* await */(s.get_value());
/* await */(s.get_arith_value());
/* await */(template_typedef_cplx4.my_func_r(s));
/* await */(template_typedef_cplx4.make_Multiplies_double_double_double_double(s, s));

//
// Here we fail
//
var d = /* await */(template_typedef_cplx4.make_Identity_double());
/* await */(template_typedef_cplx4.my_func_r(d));

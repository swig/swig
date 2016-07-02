%
% this is OK
%


s = template_typedef_cplx3.Sin();
s.get_base_value();
s.get_value();
s.get_arith_value();
template_typedef_cplx3.my_func_r(s);
template_typedef_cplx3.make_Multiplies_double_double_double_double(s,s);

z = template_typedef_cplx3.CSin();
z.get_base_value();
z.get_value();
z.get_arith_value();
template_typedef_cplx3.my_func_c(z);
template_typedef_cplx3.make_Multiplies_complex_complex_complex_complex(z,z);

%
% Here we fail
%
d = template_typedef_cplx3.make_Identity_double();
template_typedef_cplx3.my_func_r(d);

c = template_typedef_cplx3.make_Identity_complex();
template_typedef_cplx3.my_func_c(c);

  




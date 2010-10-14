package main

import "template_typedef_cplx2"
import "template_typedef_import"

func main() {
	// this is OK


	s := template_typedef_import.NewSin()
	s.Get_base_value()
	s.Get_value()
	s.Get_arith_value()
	template_typedef_import.My_func_r(s)
	template_typedef_cplx2.Make_Multiplies_double_double_double_double(s, s)

	z := template_typedef_import.NewCSin()
	z.Get_base_value()
	z.Get_value()
	z.Get_arith_value()
	template_typedef_import.My_func_c(z)
	template_typedef_cplx2.Make_Multiplies_complex_complex_complex_complex(z, z)

	// Here we fail
	d := template_typedef_cplx2.Make_Identity_double()
	template_typedef_import.My_func_r(d)

	c := template_typedef_cplx2.Make_Identity_complex()
	template_typedef_import.My_func_c(c)
}

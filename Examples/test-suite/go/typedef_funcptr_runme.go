package main

import . "swigtests/typedef_funcptr"

func main() {
	a := 100
	b := 10

	if Do_op(a,b,Addf) != 110 {
		panic(0)
	}
	if Do_op(a,b,Subf) != 90 {
		panic(0)
	}

	if Do_op_typedef_int(a,b,Addf) != 110 {
		panic(0)
	}
	if Do_op_typedef_int(a,b,Subf) != 90 {
		panic(0)
	}

	if Do_op_typedef_Integer(a,b,Addf) != 110 {
		panic(0)
	}
	if Do_op_typedef_Integer(a,b,Subf) != 90 {
		panic(0)
	}
}

package main

import . "swigtests/class_case"

func main() {
	b2 := NewClassB2()
	// This used to fail with:
	// panic: interface conversion: interface {} is class_case.SwigcptrClassB2, not int
	if Test2(b2) != 1 {
		panic("Unexpected overload used")
	}
}

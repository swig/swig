package main

import . "swigtests/director_frob"

func main() {
	foo := NewBravo()
	s := foo.Abs_method()

	if s != "Bravo::abs_method()" {
		panic(s)
	}

	// Test take_ops_intref with a non-director Ops (no virtual dispatch)
	ops := NewOps()
	ret := Take_ops_intref(ops)
	if ret != 0 {
		panic(ret)
	}
	DeleteOps(ops)
}

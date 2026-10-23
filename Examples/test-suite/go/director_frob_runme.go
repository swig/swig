package main

import . "swigtests/director_frob"

// GoOps is a director subclass that does not override operator int&()
// (renamed OpIntAmp), so a virtual call from C++ dispatches through
// SwigDirector_Ops::operator int&() and upcalls back to the C++ base.
type GoOps struct{}

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

	// Test take_ops_intref with a director Ops: the virtual call to
	// operator int&() dispatches through SwigDirector_Ops::operator int&(),
	// exercising the int& directorout typemap.
	director := NewDirectorOps(&GoOps{})
	ret = Take_ops_intref(director)
	if ret != 0 {
		panic(ret)
	}
	DeleteDirectorOps(director)
}

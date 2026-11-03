// Example using pointers to member functions

package main

import "fmt"
import . "swigtests/member_pointer"

func check(what string, expected float64, actual float64) {
	if expected != actual {
		panic(fmt.Sprintf("Failed: %s Expected: %f Actual; %f", what, expected, actual))
	}
}

func main() {
	// Get the pointers

	area_pt := Areapt()
	perim_pt := Perimeterpt()

	// Create some objects

	s := NewSquare(10)

	// Do some calculations

	check("Square area ", 100.0, Do_op(s, area_pt))
	check("Square perim", 40.0, Do_op(s, perim_pt))

	_ = GetAreavar()
	_ = GetPerimetervar()

	// Try the variables
	check("Square area ", 100.0, Do_op(s, GetAreavar()))
	check("Square perim", 40.0, Do_op(s, GetPerimetervar()))

	// Modify one of the variables
	SetAreavar(perim_pt)

	check("Square perimeter", 40.0, Do_op(s, GetAreavar()))

	// Try the constants

	_ = AREAPT
	_ = PERIMPT
	_ = NULLPT

	check("Square area ", 100.0, Do_op(s, AREAPT))
	check("Square perim", 40.0, Do_op(s, PERIMPT))

	// Const references to member pointers
	check("Square area", 100.0, Do_op_cref(s, area_pt))
	check("Square perim", 40.0, Do_op_cref(s, Perimetervar_td_cref()))
	check("Square perim", 40.0, Do_op(s, Perimetervar_td_cref()))

	// Overloaded on the member pointer type, except for ADD_BY_POINTER as Go uses one type for every member pointer
	check("Overload by value", 3, float64(Call_overloaded(ADD_BY_VALUE, 1, 2)))
	check("Overload by int", 110, float64(Call_overloaded(10, 5, 6)))

	// NULL member pointers
	if Get_null_memberpt() != nil {
		panic("Get_null_memberpt() is not nil")
	}
	if !Is_null_memberpt(nil) {
		panic("Is_null_memberpt(nil) failed")
	}
	if NULLPT != nil {
		panic("NULLPT is not nil")
	}
	if Is_null_memberpt(area_pt) {
		panic("Is_null_memberpt(area_pt) failed")
	}
	SetAreavar(nil)
	if GetAreavar() != nil {
		panic("areavar is not nil")
	}
}

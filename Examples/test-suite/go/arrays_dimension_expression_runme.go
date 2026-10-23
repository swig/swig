package main

import "fmt"
import . "swigtests/arrays_dimension_expression"

func check(expected, actual interface{}) {
	if expected != actual {
		panic(fmt.Sprintf("expected %v but got %v", expected, actual))
	}
}

func main() {
	// Setting an array with a dimension such as 'DIM_FLAGS | 4' copies all of its elements, and no more.
	SetOr_array(GetOr_source())
	check(28, Or_array_sum())
	SetOr_grid(GetOr_grid_source())
	check(21, Or_grid_sum())

	SetOr_text("abcdef")
	check("abcdef", GetOr_text())
	check(6, Or_text_length("abcdef"))

	SetAnd_array(GetAnd_source())
	check(3, And_array_sum())
	SetAnd_grid(GetAnd_grid_source())
	check(10, And_grid_sum())

	SetXor_array(GetXor_source())
	check(28, Xor_array_sum())
	SetXor_grid(GetXor_grid_source())
	check(105, Xor_grid_sum())

	SetEq_array(GetEq_source())
	check(5, Eq_array_sum())
	SetEq_grid(GetEq_grid_source())
	check(11, Eq_grid_sum())

	holder := NewDimensionHolder()
	holder.SetOr_member(GetOr_source())
	check(28, Or_member_sum(holder))
	holder.SetOr_grid_member(GetOr_grid_source())
	check(21, Or_grid_member_sum(holder))
	holder.SetOr_text_member("abcdef")
	check("abcdef", holder.GetOr_text_member())
}

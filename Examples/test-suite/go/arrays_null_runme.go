package main

import . "swigtests/arrays_null"

func checkNullRejected(name string, set func()) {
	defer func() {
		if recover() == nil {
			panic("Test " + name + " set to nil failed")
		}
	}()
	set()
}

func main() {
	s := NewArraysNull()
	other := NewArraysNull()
	Arrays_null_fill(other, 10)
	s.SetInts(other.GetInts())
	s.SetItems(other.GetItems())
	s.SetGrid(other.GetGrid())
	if Arrays_null_check(s, 10) != 1 {
		panic("Test member set failed")
	}

	checkNullRejected("ints member", func() { s.SetInts(nil) })
	checkNullRejected("items member", func() { s.SetItems(SwigcptrArraysNullItem(0)) })
	checkNullRejected("grid member", func() { s.SetGrid(nil) })
	if Arrays_null_check(s, 10) != 1 {
		panic("Test member set to nil changed it")
	}

	SetArrays_null_ints(s.GetInts())
	SetArrays_null_items(s.GetItems())
	SetArrays_null_grid(s.GetGrid())
	if Arrays_null_globals_check(10) != 1 {
		panic("Test global set failed")
	}

	checkNullRejected("ints global", func() { SetArrays_null_ints(nil) })
	checkNullRejected("items global", func() { SetArrays_null_items(SwigcptrArraysNullItem(0)) })
	checkNullRejected("grid global", func() { SetArrays_null_grid(nil) })
	checkNullRejected("ints_ref global", func() { SetArrays_null_ints_ref(nil) })
	checkNullRejected("bools global", func() { SetArrays_null_bools(nil) })
	if Arrays_null_globals_check(10) != 1 {
		panic("Test global set to nil changed it")
	}

	if Arrays_null_ints_isnull(nil) != 1 {
		panic("Test nil ints parameter failed")
	}
	if Arrays_null_ints_unsized_isnull(nil) != 1 {
		panic("Test nil ints unsized parameter failed")
	}
	if Arrays_null_enums_isnull(nil) != 1 {
		panic("Test nil enums parameter failed")
	}
	if Arrays_null_enums_unsized_isnull(nil) != 1 {
		panic("Test nil enums unsized parameter failed")
	}
	if Arrays_null_items_isnull(nil) != 1 {
		panic("Test nil items parameter failed")
	}
	if Arrays_null_items_unsized_isnull(nil) != 1 {
		panic("Test nil items unsized parameter failed")
	}
	if Arrays_null_bools_isnull(nil) != 1 {
		panic("Test nil bools parameter failed")
	}
	if Arrays_null_bools_unsized_isnull(nil) != 1 {
		panic("Test nil bools unsized parameter failed")
	}
	if Arrays_null_strings_isnull(nil) != 1 {
		panic("Test nil strings parameter failed")
	}
	if Arrays_null_strings_unsized_isnull(nil) != 1 {
		panic("Test nil strings unsized parameter failed")
	}

	// A reference to an array cannot be nil
	checkNullRejected("ints_ref parameter", func() { Arrays_null_ints_ref_first(nil) })
}

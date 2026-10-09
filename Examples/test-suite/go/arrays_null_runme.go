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
	if Arrays_null_globals_check(10) != 1 {
		panic("Test global set to nil changed it")
	}

	if Arrays_null_isnull(nil) != 1 {
		panic("Test nil array parameter failed")
	}
}

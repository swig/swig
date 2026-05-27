package main

import "swigtests/li_std_optional"

func main() {
	// Test make_optional
	v := li_std_optional.Make_optional(42)
	_ = v

	// Test make_empty_optional
	e := li_std_optional.Make_empty_optional()
	_ = e

	// Test optional_value_or
	r1 := li_std_optional.Optional_value_or(li_std_optional.Make_optional(10), 99)
	if r1 != 10 {
		panic(0)
	}

	r2 := li_std_optional.Optional_value_or(li_std_optional.Make_empty_optional(), 99)
	if r2 != 99 {
		panic(0)
	}
}

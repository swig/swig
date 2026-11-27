package main

import "fmt"
import . "swigtests/member_funcptr_galore"

func check(got int, expected int, what string) {
	if got != expected {
		panic(fmt.Sprintf("%s got %d expected %d", what, got, expected))
	}
}

func main() {
	m := NewMemberFuncPtrs()
	check(m.Aaa1(GetCc1()), 0, "aaa1")
	check(m.Aaa6(GetCc6()), 0, "aaa6")
	check(m.Aaa7(GetCc7()), 0, "aaa7")
	check(m.Bbb1(GetPp1()), 0, "bbb1")
	check(m.Bbb6(GetPp6()), 0, "bbb6")
	check(m.Bbb7(GetPp7()), 0, "bbb7")
	check(Call1(ADD_BY_VALUE, 1, 2), 3, "call1")

	// A const reference to a member pointer is passed and returned as the member pointer
	check(m.Aaa7(GetCc1()), 0, "aaa7 cc1")
	check(m.Aaa1(GetCc7()), 0, "aaa1 cc7")
}

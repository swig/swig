package main

import "fmt"

import wrap "swigtests/director_member_pointer"

func check(got int, expected int, what string) {
	if got != expected {
		panic(fmt.Sprintf("%s got %d expected %d", what, got, expected))
	}
}

func main() {
	// Go cannot name the member pointer type so these director methods are not overridden and the Go callbacks call the C++ methods
	// CallGetMemberPtr is left out as cgo does not allow a Go callback to return the Go memory holding a member pointer
	d := wrap.NewDirectorMemberPtrDirector(&struct{}{})
	defer wrap.DeleteDirectorMemberPtrDirector(d)
	check(d.CallUseMemberPtr(5), 7, "Director useMemberPtr")
}

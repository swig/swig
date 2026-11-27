package main

import "fmt"

import wrap "swigtests/director_member_pointer"

func check(got int, expected int, what string) {
	if got != expected {
		panic(fmt.Sprintf("%s got %d expected %d", what, got, expected))
	}
}

// GetMemberPtr and GetMemberPtrCref return the member pointer last passed to UseMemberPtr or UseMemberPtrCref
type MyMemberPtrDirector struct {
	stored wrap.SwigMemberPtr
}

func (p *MyMemberPtrDirector) UseMemberPtr(m wrap.SwigMemberPtr, x int) int {
	p.stored = m
	if m == nil {
		return -1
	}
	return wrap.MemberPtrDirectorCallMemberPtr(m, x+10)
}

func (p *MyMemberPtrDirector) UseMemberPtrCref(m wrap.SwigMemberPtr, x int) int {
	p.stored = m
	return wrap.MemberPtrDirectorCallMemberPtr(m, x+20)
}

func (p *MyMemberPtrDirector) GetMemberPtr() wrap.SwigMemberPtr {
	return p.stored
}

func (p *MyMemberPtrDirector) GetMemberPtrCref() wrap.SwigMemberPtr {
	return p.stored
}

func main() {
	d := wrap.NewDirectorMemberPtrDirector(&struct{}{})
	defer wrap.DeleteDirectorMemberPtrDirector(d)
	check(d.CallUseMemberPtr(5), 7, "Base useMemberPtr")
	check(d.CallUseMemberPtrCref(5), 7, "Base useMemberPtrCref")
	check(d.CallGetMemberPtr(5), 6, "Base getMemberPtr")
	check(d.CallGetMemberPtrCref(5), 6, "Base getMemberPtrCref")

	md := wrap.NewDirectorMemberPtrDirector(&MyMemberPtrDirector{})
	defer wrap.DeleteDirectorMemberPtrDirector(md)
	if !md.CallGetMemberPtrIsNull() {
		panic("Director getMemberPtr returning nil failed")
	}
	if !md.CallGetMemberPtrCrefIsNull() {
		panic("Director getMemberPtrCref returning nil failed")
	}
	check(md.CallUseMemberPtrCref(5), 27, "Director useMemberPtrCref")
	check(md.CallGetMemberPtr(5), 7, "Director getMemberPtr after useMemberPtrCref")
	check(md.CallGetMemberPtrCref(5), 7, "Director getMemberPtrCref after useMemberPtrCref")
	check(md.CallUseMemberPtr(5), 17, "Director useMemberPtr")
	check(md.CallGetMemberPtr(5), 7, "Director getMemberPtr")

	// NULL member pointers
	check(md.CallUseNullMemberPtr(5), -1, "Director useMemberPtr with a nil member pointer")
}

package main

import "fmt"

import wrap "swigtests/director_char_array"

type Director struct{}

func (p *Director) Take_array(s string) int {
	return len(s)
}

func (p *Director) Take_const_array(s string) int {
	return len(s)
}

func (p *Director) Take_array_ref(s string) int {
	return len(s)
}

func (p *Director) Take_const_array_ref(s string) int {
	return len(s)
}

func check(got int, expected int, what string) {
	if got != expected {
		panic(fmt.Sprintf("%s got %d expected %d", what, got, expected))
	}
}

func main() {
	d := wrap.NewDirectorCharArrayDirector(&Director{})
	defer wrap.DeleteDirectorCharArrayDirector(d)
	check(d.Call_take_array(), 4, "take_array")
	check(d.Call_take_const_array(), 4, "take_const_array")
	check(d.Call_take_array_ref(), 4, "take_array_ref")
	check(d.Call_take_const_array_ref(), 4, "take_const_array_ref")
	check(d.Call_take_array_short(), 2, "take_array short")
	check(d.Call_take_array_ref_short(), 2, "take_array_ref short")
}

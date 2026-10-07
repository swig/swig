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

// Go has no null string, NULL gives an empty string
func (p *Director) Is_null_array(s string) int {
	if s == "" {
		return 1
	}
	return 0
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
	check(d.Call_is_null_array(), 1, "is_null_array")
}

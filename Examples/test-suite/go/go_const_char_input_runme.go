package main

import "swigtests/go_const_char_input"

func main() {
	s := go_const_char_input.Test_typedef("hello")
	if s != "hello" {
		panic(s + " != hello")
	}
	s2 := go_const_char_input.Test_const_char("world")
	if s2 != "world" {
		panic(s2 + " != world")
	}
	s3 := go_const_char_input.Test_const_char_array("foo")
	if s3 != "foo" {
		panic(s3 + " != foo")
	}
	s4 := go_const_char_input.Test_fixed_array("bar")
	if s4 != "bar" {
		panic(s4 + " != bar")
	}
}

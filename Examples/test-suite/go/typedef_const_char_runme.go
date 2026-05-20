package main

import "swigtests/typedef_const_char"

func main() {
	// Test that typedef'd const char* is handled correctly (issue #3290).
	s := typedef_const_char.Test_typedef_const_char("hello")
	if s != "hello" {
		panic(s + " != hello")
	}
	s2 := typedef_const_char.Test_const_char("world")
	if s2 != "world" {
		panic(s2 + " != world")
	}
	s3 := typedef_const_char.Echo_typedef("foo", "bar")
	if s3 != "foo" {
		panic(s3 + " != foo")
	}
}

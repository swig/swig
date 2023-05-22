package main

import wrap "swigtests/argcargvtest"

func main() {
	largs := []string{"hi", "hola", "hello"}
	if ri := wrap.Mainc(largs); ri != 3 {
		panic(ri)
	}

	targs := []string{"hi", "hola"}
	if rs := wrap.Mainv(targs, 0); rs != "hi" {
		panic(rs)
	}
	if rs := wrap.Mainv(targs, 1); rs != "hola" {
		panic(rs)
	}
	if rs := wrap.Mainv(targs, 2); rs != "<<NULL>>" {
		panic(rs)
	}

// For dynamically typed languages we test this throws an exception or similar
// at runtime, but for Go this doesn't even compile (but we can't easily
// test for that here).
//	wrap.Mainv("hello", 1)

	wrap.InitializeApp(largs)

	// Check that an empty array works.
	empty_args := []string{};
	if ri := wrap.Mainc(empty_args); ri != 0 {
		panic(ri)
	}
	if rs := wrap.Mainv(empty_args, 0); rs != "<<NULL>>" {
		panic(rs)
	}

	// Check that empty strings are handled.
	empty_string := []string{"hello", "", "world"};
	if ri := wrap.Mainc(empty_string); ri != 3 {
		panic(ri)
	}
	if rs := wrap.Mainv(empty_string, 0); rs != "hello" {
		panic(rs)
	}
	if rs := wrap.Mainv(empty_string, 1); rs != "" {
		panic(rs)
	}
	if rs := wrap.Mainv(empty_string, 2); rs != "world" {
		panic(rs)
	}
	if rs := wrap.Mainv(empty_string, 3); rs != "<<NULL>>" {
		panic(rs)
	}
}

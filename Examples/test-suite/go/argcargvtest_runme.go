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

// For dynamically typed languages we test this throws an exception or similar
// at runtime, but for Go this doesn't even compile (but we can't easily
// test for that here).
//	wrap.Mainv("hello", 1)

	wrap.InitializeApp(largs)
}

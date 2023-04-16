package main

import wrap "swigtests/argcargvtest"

func main() {
	largs := []string{"hi", "hola", "hello"}
	if ri := wrap.Mainc(largs); ri != 3 {
		panic(ri)
	}

	targs := []string{"hi", "hola"}
	if rs := wrap.Mainv(targs, 1); rs != "hola" {
		panic(rs)
	}

//	wrap.Mainv("hello", 1)  // Fail compilation!!

	wrap.InitializeApp(largs)
}

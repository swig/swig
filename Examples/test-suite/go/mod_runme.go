package main

import "swigtests/mod_a"
import "swigtests/mod_b"

func main() {
	c := mod_b.NewC()
	d := mod_b.NewD()
	d.DoSomething(mod_a.SwigcptrA(c.Swigcptr()))
}

package main

import "swigtests/template_extend2"

func main() {
	a := template_extend2.NewLBaz()
	b := template_extend2.NewDBaz()

	if a.Foo() != "lBaz::foo" {
		panic(0)
	}

	if b.Foo() != "dBaz::foo" {
		panic(0)
	}
}

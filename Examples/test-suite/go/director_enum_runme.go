package main

import "./director_enum"

type MyFoo struct{} // From director_enum.Foo
func (p *MyFoo) Say_hi(val director_enum.EnumDirectorHelloe) director_enum.EnumDirectorHelloe {
	return val
}

func main() {
	b := director_enum.NewFoo()
	a := director_enum.NewDirectorFoo(&MyFoo{})

	if a.Say_hi(director_enum.Hello) != b.Say_hello(director_enum.Hi) {
		panic(0)
	}
}

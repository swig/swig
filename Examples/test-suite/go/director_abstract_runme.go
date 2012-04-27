package main

import "./director_abstract"

type MyFoo struct{}

func (p *MyFoo) Ping() string {
	return "MyFoo::ping()"
}

func f1() {
	a := director_abstract.NewDirectorFoo(&MyFoo{})

	if a.Ping() != "MyFoo::ping()" {
		panic(a.Ping())
	}

	if a.Pong() != "Foo::pong();MyFoo::ping()" {
		panic(a.Pong())
	}
}

type MyExample1 struct{}

func (p *MyExample1) Color(r, g, b byte) int {
	return int(r)
}

type MyExample2 struct{}

func (p *MyExample2) Color(r, g, b byte) int {
	return int(g)
}

type MyExample3 struct{}

func (p *MyExample3) Color(r, g, b byte) int {
	return int(b)
}

func f2() {
	me1 := director_abstract.NewDirectorExample1(&MyExample1{})
	if director_abstract.Example1Get_color(me1, 1, 2, 3) != 1 {
		println(director_abstract.Example1Get_color(me1, 1, 2, 3))
		panic(0)
	}

	me2 := director_abstract.NewDirectorExample2(&MyExample2{}, 1, 2)
	if director_abstract.Example2Get_color(me2, 1, 2, 3) != 2 {
		panic(0)
	}

	me3 := director_abstract.NewDirectorExample3_i(&MyExample3{})
	if director_abstract.Example3_iGet_color(me3, 1, 2, 3) != 3 {
		panic(0)
	}
}

func main() {
	f1()
	f2()
}

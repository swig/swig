package main

import (
	wrap "swigtests/go_director_inout"
)

type GoMyClass struct {}

func (p *GoMyClass) Adjust(m map[string]interface{}) wrap.GoRetStruct {
	s := ""
	for k, v := range m {
		s += k + "," + v.(string) + ";"
	}
	return wrap.GoRetStruct{s}
}

func (p *GoMyClass) S1(s string) {
	if s != "S1" {
		panic(s)
	}
}

func (p *GoMyClass) S2(s *string) {
	if *s != "S2" {
		panic(s)
	}
	*s = "R2"
}

func (p *GoMyClass) S3(s *string) {
	if *s != "S3" {
		panic(s)
	}
	*s = "R3"
}

func main() {
	a := wrap.NewDirectorMyClass(&GoMyClass{})
	m := map[string]interface{}{
		"first": "second",
	}
	s := a.Adjust(m)
	if s.Str != "first,second;" {
		panic(s)
	}

	a.S1("S1")
	str := "S2"
	a.S2(&str)
	if str != "R2" {
		panic(str)
	}
	str = "S3"
	a.S3(&str)
	if str != "R3" {
		panic(str)
	}

	a = wrap.NewDirectorMyClass(nil)
	s = a.Adjust(m)
	if s.Str != `{"first":"second"}` {
		panic(s.Str)
	}
}

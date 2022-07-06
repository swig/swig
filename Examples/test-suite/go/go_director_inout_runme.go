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

func (p *GoMyClass) S4(s []string) {
	if s[0] != "T1" {
		panic(s)
	}
	if s[1] != "T2" {
		panic(s)
	}
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

	a.CallS4([]string{ "T1", "T2" })

	a.S5(&str)
	a.S5(nil)

	a = wrap.NewDirectorMyClass(nil)
	s = a.Adjust(m)
	if s.Str != `{"first":"second"}` {
		panic(s.Str)
	}
}

package main

import . "swigtests/li_cdata"

func main() {
	s := []byte("ABC\x00abc")
	m := Malloc(256)
	Memmove(m, s)
	ss := Cdata(m, int64(7))
	if string(ss) != "ABC\x00abc" {
		panic("failed")
	}
}

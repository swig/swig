package main

import . "swigtests/char_binary_rev_len"

func main() {
	t := NewTest()
	defer DeleteTest(t)

	if t.Strlen("hile") != 4 {
		panic("bad multi-arg typemap")
	}

	if t.Strlen("hil\000") != 4 {
		panic("bad multi-arg typemap")
	}
}

package main

import . "swigtests/char_binary_rev_len"

func main() {
	t := NewTest()
	defer DeleteTest(t)

	if t.Strlen("hile") != 4 {
		panic("bad multi-arg typemap 1")
	}

	if t.Strlen("hil\000") != 4 {
		panic("bad multi-arg typemap 2")
	}

	t2 := NewTest("hile")
	defer DeleteTest(t2)

    if t2.Getisize() != 4 {
		panic("bad multi-arg typemap 3")
    }

	if t2.Strlen("hil\000a") != 5 {
		panic("bad multi-arg typemap 4")
	}
}

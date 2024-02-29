package main

import . "swigtests/char_binary"

func main() {
	t := NewTest()
	if t.Strlen("hile") != 4 {
		panic("bad multi-arg typemap")
	}
	if t.Ustrlen("hile") != 4 {
		panic("bad multi-arg typemap")
	}

	if t.Strlen("hil\000") != 4 {
		panic("bad multi-arg typemap")
	}
	if t.Ustrlen("hil\000") != 4 {
		panic("bad multi-arg typemap")
	}

	// creating a raw char*
	pc := New_pchar(5)
	Pchar_setitem(pc, 0, 'h')
	Pchar_setitem(pc, 1, 'o')
	Pchar_setitem(pc, 2, 'l')
	Pchar_setitem(pc, 3, 'a')
	Pchar_setitem(pc, 4, 0)

    /* FIXME: pc is not a string
    if t.Strlen(pc) != 4 {
        panic("bad multi-arg typemap")
    }
    if t.Ustrlen(pc) != 4 {
        panic("bad multi-arg typemap")
    }
    */

    /* FIXME: pc is not a string
    SetVar_pchar(pc)
    */
    SetVar_pchar("hola")
    if GetVar_pchar() != "hola" {
        panic("bad pointer case")
    }

    /* FIXME: pc is not a string
    SetVar_namet(pc)
    */
    SetVar_namet("hola")
    if GetVar_namet() != "hola" {
        panic("bad pointer case")
    }

	Delete_pchar(pc)
}

package main

import "swigtests/preproc_constants"

func main() {
	if preproc_constants.CONST_STRING4 != "zer\x00zer\x00" {
		panic(0)
	}
}

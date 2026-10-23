package main

import "swigtests/string_constants"

func main() {
	if string_constants.EN1 != "a\x00bc" || string_constants.EN2 != "a\x00bc" {
		panic("EN1 or EN2")
	}
}

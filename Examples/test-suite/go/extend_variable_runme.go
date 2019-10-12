package main

import . "swigtests/extend_variable"

func main() {
	if FooBar != 42 {
		panic(0)
	}
}

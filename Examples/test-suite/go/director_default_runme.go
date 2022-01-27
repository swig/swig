package main

import . "swigtests/director_default"

func main() {
	NewFoo()
	NewFoo(1)

	NewBar()
	NewBar(1)
}

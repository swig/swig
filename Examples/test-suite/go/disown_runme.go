package main

import . "swigtests/disown"

func main() {
	a := NewA()

	b := NewB()
	b.Acquire(a)
}

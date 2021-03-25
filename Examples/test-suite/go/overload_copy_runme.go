package main

import . "swigtests/overload_copy"

func main() {
	f := NewFoo()
	_ = NewFoo(f)
}

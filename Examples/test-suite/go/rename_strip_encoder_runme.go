package main

import . "swigtests/rename_strip_encoder"

func main() {
	_ = NewSomeWidget()
	a := NewAnotherWidget()
	a.DoSomething()
}

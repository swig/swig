package main

import . "./director_thread"

type Derived struct {
	abi Foo
} // From Foo
func (p *Derived) Do_foo() {
	p.abi.SetVal(p.abi.GetVal() - 1)
}

func main() {

	// FIXME: This test fails until we fix callbacks from a
	// different thread.
	return

	p := &Derived{nil}
	d := NewDirectorFoo(p)
	p.abi = d
	d.Run()

	if d.GetVal() >= 0 {
		panic(d.GetVal())
	}

	d.Stop()
}

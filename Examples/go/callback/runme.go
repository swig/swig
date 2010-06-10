package main

import (
	"fmt"
	. "./example"
)

func main() {
	fmt.Println("Adding and calling a normal C++ callback")
	fmt.Println("----------------------------------------")

	caller := NewCaller()
	callback := NewCallback()

	caller.SetCallback(callback)
	caller.Call()
	caller.DelCallback()

	callback = NewDirectorCallback(new(GoCallback))

	fmt.Println()
	fmt.Println("Adding and calling a Go callback")
	fmt.Println("------------------------------------")

	caller.SetCallback(callback)
	caller.Call()
	caller.DelCallback()

	// Test that a double delete does not occur as the object has
	// already been deleted from the C++ layer.
	DeleteDirectorCallback(callback)

	fmt.Println()
	fmt.Println("Go exit")
}

type GoCallback struct{}

func (p *GoCallback) Run() {
	fmt.Println("GoCallback.Run")
}

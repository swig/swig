package main

import "./overload_polymorphic"

func main(){
	t := overload_polymorphic.NewDerived()
	
	if overload_polymorphic.Test(t) != 0 {
		panic("failed")
	}
}

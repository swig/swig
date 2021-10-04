package main

import "swigtests/class_ignore"

func main() {
	a := class_ignore.NewBar()
	if class_ignore.Do_blah(a) != "Bar::blah" {
		panic(class_ignore.Do_blah(a))
	}
}

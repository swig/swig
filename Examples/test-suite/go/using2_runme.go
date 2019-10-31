package main

import "swigtests/using2"

func main() {
	if using2.Spam(37) != 37 {
		panic(0)
	}
}

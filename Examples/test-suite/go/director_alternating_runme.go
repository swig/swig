package main

import . "swigtests/director_alternating"

func main() {
	id := GetBar().Id()
	if id != IdFromGetBar() {
		panic(id)
	}
}

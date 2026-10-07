package main

import . "swigtests/arrayref"

func main() {
	// Setting a variable that is a reference to an array copies into the array it refers to.
	if Numbers_sum() != 10 {
		panic("numbers_sum")
	}
	SetNumbers_ref(Others_address())
	if Numbers_sum() != 100 {
		panic("numbers_sum after set")
	}

	// An array of char is a string here, and so is a reference to one.
	if GetLetters() != "abc" {
		panic("letters")
	}
	if GetLetters_ref() != "abc" {
		panic("letters_ref")
	}
	SetLetters_ref("xy")
	if Letters_are() != "xy" {
		panic("letters_are")
	}
	if GetFrozen_ref() != "xyz" {
		panic("frozen_ref")
	}

	member := NewArrayRefMember()
	if member.Sum() != 10 {
		panic("member sum")
	}
	if member.GetText_ref() != "hi" {
		panic("member text_ref")
	}
	member.SetText_ref("bye")
	if member.Text_is() != "bye" {
		panic("member text_is")
	}
}

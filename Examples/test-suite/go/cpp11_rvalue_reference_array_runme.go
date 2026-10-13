package main

import . "swigtests/cpp11_rvalue_reference_array"

func checkNullRejected(name string, call func()) {
	defer func() {
		if recover() == nil {
			panic(name + " did not panic")
		}
	}()
	call()
}

func main() {
	// An rvalue reference to an array is passed as a reference to an array, which cannot be nil.
	if Sum_of(Others_address()) != 100 {
		panic("sum_of")
	}
	if First_of(Others_unsized_address()) != 10 {
		panic("first_of")
	}
	if Items_sum(Items_address()) != 3 {
		panic("items_sum")
	}
	checkNullRejected("sum_of(nil)", func() { Sum_of(nil) })
	checkNullRejected("first_of(nil)", func() { First_of(nil) })

	// An rvalue reference to an array of char is a string.
	if Length_of("abc") != 3 {
		panic("length_of")
	}
	if Length_of_writable("xy") != 2 {
		panic("length_of_writable")
	}

	// Setting a variable that is an rvalue reference to an array copies into the array it refers to.
	if Numbers_sum() != 10 {
		panic("numbers_sum")
	}
	SetNumbers_rref(Others_address())
	if Numbers_sum() != 100 {
		panic("numbers_sum after set")
	}
	if GetLetters_rref() != "abc" {
		panic("letters_rref")
	}
	SetLetters_rref("xy")
	if Letters_are() != "xy" {
		panic("letters_are")
	}

	member := NewRvalueRefArrayMember()
	if member.Sum() != 10 {
		panic("member sum")
	}
	member.SetMember_rref(Others_address())
	if member.Sum() != 100 {
		panic("member sum after set")
	}
	if member.GetText_rref() != "hi" {
		panic("member text_rref")
	}
	member.SetText_rref("bye")
	if member.Text_is() != "bye" {
		panic("member text_is")
	}
}

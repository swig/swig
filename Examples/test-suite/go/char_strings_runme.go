package main

import (
	"strconv"
	"swigtests/char_strings"
)

const CPLUSPLUS_MSG = "A message from the deep dark world of C++, where anything is possible."
const OTHERLAND_MSG = "Little message from the safe world."

func main() {
	const count = 1000

	// get functions
	for i := uint(0); i < count; i++ {
		if char_strings.GetCharHeapString() != CPLUSPLUS_MSG {
			panic("Test char get 1 failed, iteration " + strconv.Itoa(int(i)))
		}
		char_strings.DeleteCharHeapString()
	}

	for i := uint(0); i < count; i++ {
		if char_strings.GetConstCharProgramCodeString() != CPLUSPLUS_MSG {
			panic("Test char get 2 failed, iteration " + strconv.Itoa(int(i)))
		}
		char_strings.DeleteCharHeapString()
	}

	for i := uint(0); i < count; i++ {
		if char_strings.GetCharStaticString() != CPLUSPLUS_MSG {
			panic("Test char get 3 failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	for i := uint(0); i < count; i++ {
		if char_strings.GetCharStaticStringFixed() != CPLUSPLUS_MSG {
			panic("Test char get 4 failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	for i := uint(0); i < count; i++ {
		if char_strings.GetConstCharStaticStringFixed() != CPLUSPLUS_MSG {
			panic("Test char get 5 failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	// set functions
	for i := uint(0); i < count; i++ {
		if !char_strings.SetCharHeapString(OTHERLAND_MSG+strconv.Itoa(int(i)), i) {
			panic("Test char set 1 failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	for i := uint(0); i < count; i++ {
		if !char_strings.SetCharStaticString(OTHERLAND_MSG+strconv.Itoa(int(i)), i) {
			panic("Test char set 2 failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	for i := uint(0); i < count; i++ {
		if !char_strings.SetCharArrayStaticString(OTHERLAND_MSG+strconv.Itoa(int(i)), i) {
			panic("Test char set 3 failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	for i := uint(0); i < count; i++ {
		if !char_strings.SetConstCharHeapString(OTHERLAND_MSG+strconv.Itoa(int(i)), i) {
			panic("Test char set 4 failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	for i := uint(0); i < count; i++ {
		if !char_strings.SetConstCharStaticString(OTHERLAND_MSG+strconv.Itoa(int(i)), i) {
			panic("Test char set 5 failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	for i := uint(0); i < count; i++ {
		if !char_strings.SetConstCharArrayStaticString(OTHERLAND_MSG+strconv.Itoa(int(i)), i) {
			panic("Test char set 6 failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	for i := uint(0); i < count; i++ {
		if !char_strings.SetCharConstStaticString(OTHERLAND_MSG+strconv.Itoa(int(i)), i) {
			panic("Test char set 7 failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	for i := uint(0); i < count; i++ {
		if !char_strings.SetConstCharConstStaticString(OTHERLAND_MSG+strconv.Itoa(int(i)), i) {
			panic("Test char set 8 failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	for i := uint(0); i < count; i++ {
		if !char_strings.SetConstCharTypedefString(OTHERLAND_MSG+strconv.Itoa(int(i)), i) {
			panic("Test char set 9 failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	// get set function
	for i := uint(0); i < count*10; i++ {
		ping := OTHERLAND_MSG + strconv.Itoa(int(i))
		pong := char_strings.CharPingPong(ping)
		if ping != pong {
			panic("Test PingPong 1 failed.\nExpected:" + ping + "\nReceived:" + pong)
		}
	}

	for i := uint(0); i < count; i++ {
		ping := OTHERLAND_MSG + strconv.Itoa(int(i))
		pong := char_strings.CharArrayPingPong(ping)
		if ping != pong {
			panic("Test PingPong 2 failed.\nExpected:" + ping + "\nReceived:" + pong)
		}
	}

	for i := uint(0); i < count; i++ {
		ping := OTHERLAND_MSG + strconv.Itoa(int(i))
		pong := char_strings.CharArrayDimsPingPong(ping)
		if ping != pong {
			panic("Test PingPong 3 failed.\nExpected:" + ping + "\nReceived:" + pong)
		}
	}

	// variables
	for i := uint(0); i < count; i++ {
		expected := OTHERLAND_MSG + strconv.Itoa(int(i))
		char_strings.SetGlobal_char(expected)
		if char_strings.GetGlobal_char() != expected {
			panic("Test variables 1 failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	for i := uint(0); i < count; i++ {
		expected := OTHERLAND_MSG + strconv.Itoa(int(i))
		char_strings.SetGlobal_char_array1(expected)
		if char_strings.GetGlobal_char_array1() != expected {
			panic("Test variables 2 failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	for i := uint(0); i < count; i++ {
		expected := OTHERLAND_MSG + strconv.Itoa(int(i))
		char_strings.SetGlobal_char_array2(expected)
		if char_strings.GetGlobal_char_array2() != expected {
			panic("Test variables 3 failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	for i := uint(0); i < count; i++ {
		if char_strings.GetGlobal_const_char() != CPLUSPLUS_MSG {
			panic("Test variables 4 failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	for i := uint(0); i < count; i++ {
		if char_strings.GetGlobal_const_char_array1() != CPLUSPLUS_MSG {
			panic("Test variables 5 failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	for i := uint(0); i < count; i++ {
		if char_strings.GetGlobal_const_char_array2() != CPLUSPLUS_MSG {
			panic("Test variables 6 failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	// char *& tests
	for i := uint(0); i < count; i++ {
		if char_strings.GetCharPointerRef() != CPLUSPLUS_MSG {
			panic("Test char pointer ref get failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	for i := uint(0); i < count; i++ {
		if !char_strings.SetCharPointerRef(OTHERLAND_MSG+strconv.Itoa(int(i)), i) {
			panic("Test char pointer ref set failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	for i := uint(0); i < count; i++ {
		if char_strings.GetConstCharPointerRef() != CPLUSPLUS_MSG {
			panic("Test const char pointer ref get failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	for i := uint(0); i < count; i++ {
		if !char_strings.SetConstCharPointerRef(OTHERLAND_MSG+strconv.Itoa(int(i)), i) {
			panic("Test const char pointer ref set failed, iteration " + strconv.Itoa(int(i)))
		}
	}
}

package main

import (
	"strconv"
	"swigtests/char_strings"
)

const CPLUSPLUS_MSG = "A message from the deep dark world of C++, where anything is possible."
const OTHERLAND_MSG = "Little message from the safe world."

func panics(f func()) (panicked bool) {
	defer func() {
		panicked = recover() != nil
	}()
	f()
	return
}

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
		ping := "Ping" + strconv.Itoa(int(i)) // char[16] buffer, keep short enough to fit
		pong := char_strings.CharArrayDimsPingPong(ping)
		if ping != pong {
			panic("Test PingPong 3 failed.\nExpected:" + ping + "\nReceived:" + pong)
		}
	}

	if char_strings.CharArrayDimsLength("Ping") != 4 {
		panic("Test CharArrayDimsLength failed")
	}
	if char_strings.CharArrayDimsLength("0123456789abcde") != 15 {
		panic("Test CharArrayDimsLength failed")
	}
	if !panics(func() { char_strings.CharArrayDimsLength("0123456789abcdef") }) {
		panic("Test CharArrayDimsLength overlong string failed")
	}

	// variables
	for i := uint(0); i < count; i++ {
		expected := OTHERLAND_MSG + strconv.Itoa(int(i))
		char_strings.SetGlobal_char(expected)
		if char_strings.GetGlobal_char() != expected {
			panic("Test variables 1 failed, iteration " + strconv.Itoa(int(i)))
		}
	}

	// global_char_array1 is a char[] with no size, so it is read only
	if char_strings.GetGlobal_char_array1() != CPLUSPLUS_MSG {
		panic("Test variables 2 failed")
	}

	for i := uint(0); i < count; i++ {
		expected := OTHERLAND_MSG + strconv.Itoa(int(i))
		char_strings.SetGlobal_char_array2(expected)
		if char_strings.GetGlobal_char_array2() != expected {
			panic("Test variables 3 failed, iteration " + strconv.Itoa(int(i)))
		}
	}
	if !panics(func() { char_strings.SetGlobal_char_array2(CPLUSPLUS_MSG + CPLUSPLUS_MSG) }) {
		panic("Test variables 3 overlong string failed")
	}
	if char_strings.GetChar_array_no_nul().GetFull() != "abcd" || char_strings.GetChar_array_no_nul().GetAfter() != "XYZ" {
		panic("Test full char array failed")
	}
	char_strings.SetGlobal_char_one("a")
	one := char_strings.NewCharArrayOne()
	one.SetOne("b")
	if char_strings.GetGlobal_char_one() != "a" || one.GetOne() != "b" {
		panic("Test char[1] failed")
	}

	// Go has no null string, so test an empty string is passed as one
	if char_strings.CharArrayPingPong("") != "" || char_strings.CharArrayDimsPingPong("") != "" {
		panic("Test char array empty string failed")
	}
	if char_strings.PlainCharPingPong('a') != 'a' {
		panic("Test char failed")
	}
	nullMember := char_strings.GetChar_array_null()
	if nullMember.GetFour() != "qqq" || char_strings.GetGlobal_char_array_null() != "qqq" {
		panic("Test char array initial value failed")
	}
	nullMember.SetFour("")
	char_strings.SetGlobal_char_array_null("")
	if nullMember.GetFour() != "" || char_strings.GetGlobal_char_array_null() != "" {
		panic("Test char array set to empty string failed")
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

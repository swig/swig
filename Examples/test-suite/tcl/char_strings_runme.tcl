if [ catch { load ./char_strings[info sharedlibextension] Char_strings} err ] {
    puts stderr "Could not load shared object:\n$err"
    exit 1
}

set CPLUSPLUS_MSG "A message from the deep dark world of C++, where anything is possible."
set OTHERLAND_MSG "Little message from the safe world."

# get functions
if {[GetCharHeapString] != $CPLUSPLUS_MSG} { error "Test char get 1 failed" }
DeleteCharHeapString

if {[GetConstCharProgramCodeString] != $CPLUSPLUS_MSG} { error "Test char get 2 failed" }

if {[GetCharStaticString] != $CPLUSPLUS_MSG} { error "Test char get 3 failed" }

if {[GetCharStaticStringFixed] != $CPLUSPLUS_MSG} { error "Test char get 4 failed" }

if {[GetConstCharStaticStringFixed] != $CPLUSPLUS_MSG} { error "Test char get 5 failed" }

# set functions - Set(OTHERLAND_MSG + number, number) must return true (1)
if {[SetCharHeapString "${OTHERLAND_MSG}1" 1] != 1} { error "Test char set 1 failed" }
if {[SetCharStaticString "${OTHERLAND_MSG}2" 2] != 1} { error "Test char set 2 failed" }
if {[SetCharArrayStaticString "${OTHERLAND_MSG}3" 3] != 1} { error "Test char set 3 failed" }
if {[SetConstCharHeapString "${OTHERLAND_MSG}4" 4] != 1} { error "Test char set 4 failed" }
if {[SetConstCharStaticString "${OTHERLAND_MSG}5" 5] != 1} { error "Test char set 5 failed" }
if {[SetConstCharArrayStaticString "${OTHERLAND_MSG}6" 6] != 1} { error "Test char set 6 failed" }
if {[SetCharConstStaticString "${OTHERLAND_MSG}7" 7] != 1} { error "Test char set 7 failed" }
if {[SetConstCharConstStaticString "${OTHERLAND_MSG}8" 8] != 1} { error "Test char set 8 failed" }
if {[SetConstCharTypedefString "${OTHERLAND_MSG}9" 9] != 1} { error "Test char set 9 failed" }

# get set functions (ping pong round trip)
set ping "${OTHERLAND_MSG}11"
if {[CharPingPong $ping] != $ping} { error "Test PingPong 1 failed" }

set ping "${OTHERLAND_MSG}12"
if {[CharArrayPingPong $ping] != $ping} { error "Test PingPong 2 failed" }

# CharArrayDimsPingPong takes char[16], so the string must fit in 15 chars + nul
set ping "PingPong 13"
if {[CharArrayDimsPingPong $ping] != $ping} { error "Test PingPong 3 failed" }

# variables
set expected "${OTHERLAND_MSG}21"
set global_char $expected
if {$global_char != $expected} { error "Test variables 1 failed (global_char set+read)" }

# global_char_array1 is read-only in Tcl (char[] has no varin typemap), so only read it
if {$global_char_array1 != $CPLUSPLUS_MSG} { error "Test variables 2 failed (global_char_array1 read)" }

set expected "${OTHERLAND_MSG}23"
set global_char_array2 $expected
if {$global_char_array2 != $expected} { error "Test variables 3 failed (global_char_array2 set+read)" }

# Tcl has no null string, so test an empty string is passed as one
if {[CharArrayPingPong ""] != "" || [CharArrayDimsPingPong ""] != ""} { error "Test char array empty string failed" }
if {[PlainCharPingPong "a"] != "a"} { error "Test char failed" }
if {[CharArrayNull_four_get $char_array_null] != "qqq" || $global_char_array_null != "qqq"} { error "Test char array initial value failed" }
CharArrayNull_four_set $char_array_null ""
set global_char_array_null ""
if {[CharArrayNull_four_get $char_array_null] != "" || $global_char_array_null != ""} { error "Test char array set to empty string failed" }

if {$global_const_char != $CPLUSPLUS_MSG} { error "Test variables 4 failed (global_const_char read-only)" }
if {$global_const_char_array1 != $CPLUSPLUS_MSG} { error "Test variables 5 failed (global_const_char_array1 read-only)" }
if {$global_const_char_array2 != $CPLUSPLUS_MSG} { error "Test variables 6 failed (global_const_char_array2 read-only)" }

# char *& tests
if {[GetCharPointerRef] != $CPLUSPLUS_MSG} { error "Test char *& get 1 failed" }
if {[SetCharPointerRef "${OTHERLAND_MSG}31" 31] != 1} { error "Test char *& set 2 failed" }
if {[GetConstCharPointerRef] != $CPLUSPLUS_MSG} { error "Test char *& get 3 failed" }
if {[SetConstCharPointerRef "${OTHERLAND_MSG}33" 33] != 1} { error "Test char *& set 4 failed" }

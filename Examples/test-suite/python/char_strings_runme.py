import char_strings
from char_strings import *

CPLUSPLUS_MSG = "A message from the deep dark world of C++, where anything is possible."
OTHERLAND_MSG = "Little message from the safe world."

count = 10


def check_equal(got, expected, msg):
    if got != expected:
        raise RuntimeError(msg + "\nExpected:" + str(expected) + "\nReceived:" + str(got))


# get functions
for i in range(count):
    check_equal(GetCharHeapString(), CPLUSPLUS_MSG, "Test char get 1 failed, iteration %d" % i)
    DeleteCharHeapString()

for i in range(count):
    check_equal(GetConstCharProgramCodeString(), CPLUSPLUS_MSG, "Test char get 2 failed, iteration %d" % i)
    DeleteCharHeapString()

for i in range(count):
    check_equal(GetCharStaticString(), CPLUSPLUS_MSG, "Test char get 3 failed, iteration %d" % i)

for i in range(count):
    check_equal(GetCharStaticStringFixed(), CPLUSPLUS_MSG, "Test char get 4 failed, iteration %d" % i)

for i in range(count):
    check_equal(GetConstCharStaticStringFixed(), CPLUSPLUS_MSG, "Test char get 5 failed, iteration %d" % i)

# set functions
for i in range(count):
    if not SetCharHeapString(OTHERLAND_MSG + str(i), i):
        raise RuntimeError("Test char set 1 failed, iteration %d" % i)

for i in range(count):
    if not SetCharStaticString(OTHERLAND_MSG + str(i), i):
        raise RuntimeError("Test char set 2 failed, iteration %d" % i)

for i in range(count):
    if not SetCharArrayStaticString(OTHERLAND_MSG + str(i), i):
        raise RuntimeError("Test char set 3 failed, iteration %d" % i)

for i in range(count):
    if not SetConstCharHeapString(OTHERLAND_MSG + str(i), i):
        raise RuntimeError("Test char set 4 failed, iteration %d" % i)

for i in range(count):
    if not SetConstCharStaticString(OTHERLAND_MSG + str(i), i):
        raise RuntimeError("Test char set 5 failed, iteration %d" % i)

for i in range(count):
    if not SetConstCharArrayStaticString(OTHERLAND_MSG + str(i), i):
        raise RuntimeError("Test char set 6 failed, iteration %d" % i)

for i in range(count):
    if not SetCharConstStaticString(OTHERLAND_MSG + str(i), i):
        raise RuntimeError("Test char set 7 failed, iteration %d" % i)

for i in range(count):
    if not SetConstCharConstStaticString(OTHERLAND_MSG + str(i), i):
        raise RuntimeError("Test char set 8 failed, iteration %d" % i)

for i in range(count):
    if not SetConstCharTypedefString(OTHERLAND_MSG + str(i), i):
        raise RuntimeError("Test char set 9 failed, iteration %d" % i)

# get set function
for i in range(count):
    ping = OTHERLAND_MSG + str(i)
    pong = CharPingPong(ping)
    check_equal(pong, ping, "Test PingPong 1 failed.")

for i in range(count):
    ping = OTHERLAND_MSG + str(i)
    pong = CharArrayPingPong(ping)
    check_equal(pong, ping, "Test PingPong 2 failed.")

for i in range(count):
    ping = "Ping" + str(i)  # char[16] buffer, keep short enough to fit
    pong = CharArrayDimsPingPong(ping)
    check_equal(pong, ping, "Test PingPong 3 failed.")

# variables
for i in range(count):
    expected = OTHERLAND_MSG + str(i)
    char_strings.cvar.global_char = expected
    check_equal(char_strings.cvar.global_char, expected, "Test variables 1 failed, iteration %d" % i)

for i in range(count):
    # global_char_array1 is of type char[] whose varin typemap is undefined
    # (SWIGWARN_TYPEMAP_VARIN_UNDEF), so it is exposed read-only in Python and
    # cannot be set. Verify it can still be read (retains its C++ initial value).
    check_equal(char_strings.cvar.global_char_array1, CPLUSPLUS_MSG, "Test variables 2 failed, iteration %d" % i)

for i in range(count):
    expected = OTHERLAND_MSG + str(i)
    char_strings.cvar.global_char_array2 = expected
    check_equal(char_strings.cvar.global_char_array2, expected, "Test variables 3 failed, iteration %d" % i)

for i in range(count):
    check_equal(char_strings.cvar.global_const_char, CPLUSPLUS_MSG, "Test variables 4 failed, iteration %d" % i)

for i in range(count):
    check_equal(char_strings.cvar.global_const_char_array1, CPLUSPLUS_MSG, "Test variables 5 failed, iteration %d" % i)

for i in range(count):
    check_equal(char_strings.cvar.global_const_char_array2, CPLUSPLUS_MSG, "Test variables 6 failed, iteration %d" % i)

# char *& tests
for i in range(count):
    check_equal(GetCharPointerRef(), CPLUSPLUS_MSG, "Test char pointer ref get failed, iteration %d" % i)

for i in range(count):
    if not SetCharPointerRef(OTHERLAND_MSG + str(i), i):
        raise RuntimeError("Test char pointer ref set failed, iteration %d" % i)

for i in range(count):
    check_equal(GetConstCharPointerRef(), CPLUSPLUS_MSG, "Test const char pointer ref get failed, iteration %d" % i)

for i in range(count):
    if not SetConstCharPointerRef(OTHERLAND_MSG + str(i), i):
        raise RuntimeError("Test const char pointer ref set failed, iteration %d" % i)

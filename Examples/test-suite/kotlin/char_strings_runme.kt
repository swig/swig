@file:JvmName("char_strings_runme")

import char_strings.*

val CPLUSPLUS_MSG = "A message from the deep dark world of C++, where anything is possible."
val OTHERLAND_MSG = "Little message from the safe world."

fun main() {
    try {
        System.loadLibrary("char_strings")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val count = 10000L

    // get functions
    for (i in 0 until count) {
        val str = char_strings.GetCharHeapString()
        if (str != CPLUSPLUS_MSG)
            throw RuntimeException("Test char get 1 failed, iteration " + i)
        char_strings.DeleteCharHeapString()
    }

    for (i in 0 until count) {
        val str = char_strings.GetConstCharProgramCodeString()
        if (str != CPLUSPLUS_MSG)
            throw RuntimeException("Test char get 2 failed, iteration " + i)
        char_strings.DeleteCharHeapString()
    }

    for (i in 0 until count) {
        val str = char_strings.GetCharStaticString()
        if (str != CPLUSPLUS_MSG)
            throw RuntimeException("Test char get 3 failed, iteration " + i)
    }

    for (i in 0 until count) {
        val str = char_strings.GetCharStaticStringFixed()
        if (str != CPLUSPLUS_MSG)
            throw RuntimeException("Test char get 4 failed, iteration " + i)
    }

    for (i in 0 until count) {
        val str = char_strings.GetConstCharStaticStringFixed()
        if (str != CPLUSPLUS_MSG)
            throw RuntimeException("Test char get 5 failed, iteration " + i)
    }

    // set functions
    for (i in 0 until count) {
        if (!char_strings.SetCharHeapString(OTHERLAND_MSG + i, i))
            throw RuntimeException("Test char set 1 failed, iteration " + i)
    }

    for (i in 0 until count) {
        if (!char_strings.SetCharStaticString(OTHERLAND_MSG + i, i))
            throw RuntimeException("Test char set 2 failed, iteration " + i)
    }

    for (i in 0 until count) {
        if (!char_strings.SetCharArrayStaticString(OTHERLAND_MSG + i, i))
            throw RuntimeException("Test char set 3 failed, iteration " + i)
    }

    for (i in 0 until count) {
        if (!char_strings.SetConstCharHeapString(OTHERLAND_MSG + i, i))
            throw RuntimeException("Test char set 4 failed, iteration " + i)
    }

    for (i in 0 until count) {
        if (!char_strings.SetConstCharStaticString(OTHERLAND_MSG + i, i))
            throw RuntimeException("Test char set 5 failed, iteration " + i)
    }

    for (i in 0 until count) {
        if (!char_strings.SetConstCharArrayStaticString(OTHERLAND_MSG + i, i))
            throw RuntimeException("Test char set 6 failed, iteration " + i)
    }

    for (i in 0 until count) {
        if (!char_strings.SetCharConstStaticString(OTHERLAND_MSG + i, i))
            throw RuntimeException("Test char set 7 failed, iteration " + i)
    }

    for (i in 0 until count) {
        if (!char_strings.SetConstCharConstStaticString(OTHERLAND_MSG + i, i))
            throw RuntimeException("Test char set 8 failed, iteration " + i)
    }

    // get set function
    for (i in 0 until count) {
        val ping = OTHERLAND_MSG + i
        val pong = char_strings.CharPingPong(ping)
        if (ping != pong)
            throw RuntimeException("Test PingPong 1 failed.\nExpected:" + ping + "\nReceived:" + pong)
    }

    // variables
    for (i in 0 until count) {
        char_strings.global_char = OTHERLAND_MSG + i
        if (char_strings.global_char != OTHERLAND_MSG + i)
            throw RuntimeException("Test variables 1 failed, iteration " + i)
    }

    for (i in 0 until count) {
        char_strings.global_char_array1 = OTHERLAND_MSG + i
        if (char_strings.global_char_array1 != OTHERLAND_MSG + i)
            throw RuntimeException("Test variables 2 failed, iteration " + i)
    }

    for (i in 0 until count) {
        char_strings.global_char_array2 = OTHERLAND_MSG + i
        if (char_strings.global_char_array2 != OTHERLAND_MSG + i)
            throw RuntimeException("Test variables 3 failed, iteration " + i)
    }

    for (i in 0 until count) {
        if (char_strings.global_const_char != CPLUSPLUS_MSG)
            throw RuntimeException("Test variables 4 failed, iteration " + i)
    }

    for (i in 0 until count) {
        if (char_strings.global_const_char_array1 != CPLUSPLUS_MSG)
            throw RuntimeException("Test variables 5 failed, iteration " + i)
    }

    for (i in 0 until count) {
        if (char_strings.global_const_char_array2 != CPLUSPLUS_MSG)
            throw RuntimeException("Test variables 6 failed, iteration " + i)
    }

    // char *& tests
    for (i in 0 until count) {
        val str = char_strings.GetCharPointerRef()
        if (str != CPLUSPLUS_MSG)
            throw RuntimeException("Test char pointer ref get failed, iteration " + i)
    }

    for (i in 0 until count) {
        if (!char_strings.SetCharPointerRef(OTHERLAND_MSG + i, i))
            throw RuntimeException("Test char pointer ref set failed, iteration " + i)
    }

    for (i in 0 until count) {
        val str = char_strings.GetConstCharPointerRef()
        if (str != CPLUSPLUS_MSG)
            throw RuntimeException("Test const char pointer ref get failed, iteration " + i)
    }

    for (i in 0 until count) {
        if (!char_strings.SetConstCharPointerRef(OTHERLAND_MSG + i, i))
            throw RuntimeException("Test const char pointer ref set failed, iteration " + i)
    }
}

@file:JvmName("java_lib_various_runme")

// Test case to check typemaps in various.i
//
// The unsigned char *NIOBUFFER typemap is not exercised - see the comment in
// java_lib_various.i for the reason.
//
// The STRING_ARRAY global variable (languages) is generated with a NON-NULL Kotlin type
// (Array<String>), so the Java test's "set languages to null / expect null getter" path is not
// representable from the runme side and is omitted; everything else is ported faithfully.

import java_lib_various.*

fun main() {
    try {
        System.loadLibrary("java_lib_various")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // STRING_ARRAY typemap parameter
    val animals = arrayOf("Cat", "Dog", "Cow", "Goat")
    if (java_lib_various.check_animals(animals) != 1)
        throw RuntimeException("check_animals failed")

    // STRING_ARRAY typemap return value
    val expected = arrayOf("Dave", "Mike", "Susan", "John", "Michelle")
    val got = java_lib_various.get_names()
    for (i in got.indices)
        if (got[i] != expected[i])
            throw RuntimeException("Name failed $i ${got[i]}|${expected[i]}")

    // STRING_ARRAY variable getter
    val langscheck = arrayOf("Hungarian", "Afrikaans", "Norwegian")
    var langs = java_lib_various.languages
    for (i in langs.indices)
        if (langs[i] != langscheck[i])
            throw RuntimeException("Languages read failed $i ${langs[i]}|${langscheck[i]}")

    // STRING_ARRAY variable setter
    val newLangs = arrayOf("French", "Italian", "Spanish")
    java_lib_various.languages = newLangs

    // STRING_ARRAY variable getter
    langs = java_lib_various.languages
    for (i in langs.indices)
        if (langs[i] != newLangs[i])
            throw RuntimeException("Languages verify failed $i ${langs[i]}|${newLangs[i]}")

    // STRING_RET test
    run {
        val stringOutArray = arrayOf("")
        java_lib_various.char_ptr_ptr_out(stringOutArray)
        if (stringOutArray[0] != "returned string")
            throw RuntimeException("Test failed: expected: returned string. got: ${stringOutArray[0]}")
    }

    // STRING_RET empty array test. Check that exception is thrown.
    try {
        val stringOutArray = arrayOf<String>()
        java_lib_various.char_ptr_ptr_out(stringOutArray)
        throw RuntimeException("Test failed: empty array")
    } catch (e: IndexOutOfBoundsException) {
    }

    // BYTE typemap check
    val b = ByteArray(20)
    java_lib_various.charout(b)
    val byjovestring = "by jove"
    val byjove = byjovestring.toByteArray()
    for (i in byjovestring.indices) {
        if (byjove[i] != b[i])
            throw RuntimeException("By jove, it failed: [${String(b)}]")
    }
}

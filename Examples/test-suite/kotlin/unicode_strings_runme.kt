@file:JvmName("unicode_strings_runme")

import unicode_strings.*

fun check(actual: String?, expected: String, msg: String) {
    if (actual != expected)
        throw RuntimeException("fail: " + msg)
}

fun main() {
    try {
        System.loadLibrary("unicode_strings")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // U+00E9 Latin small letter e with Acute
    // U+00F6 Latin small letter o with Diaeresis
    var test_string = "h\u00e9llo w\u00f6rld"
    check(unicode_strings.non_utf8_c_str(), test_string, "non_utf8_c_str")
    check(unicode_strings.non_utf8_std_string(), test_string, "non_utf8_std_string")

    // U+2192 Rightwards Arrow
    var test_arrow = "arrow\u2192right"
    check(unicode_strings.charstring(test_arrow), test_arrow, "test_arrow")

    // U+0536 ARMENIAN CAPITAL LETTER ZA
    // U+00AC NOT SIGN
    var test2 = "\u0536\t\u00ac"
    check(unicode_strings.charstring(test2), test2, "test2")
    // Java convert zero to 0xC0 0x80, so C pass it back as is!
    var test3 = "\u0536\t\u00ac\u0000afterNull"
    check(unicode_strings.charstring(test3), test3, "test3")
}

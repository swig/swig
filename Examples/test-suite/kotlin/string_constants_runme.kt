@file:JvmName("string_constants_runme")

import string_constants.*

fun check(actual: String?, expected: String, msg: String) {
    if (actual != expected)
        throw RuntimeException("fail: " + msg)
}

fun main() {
    try {
        System.loadLibrary("string_constants")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Compile-time constants keep their full value, including embedded nulls.
    check(string_constants.SS1, "\u00C6\u00CEOU\n", "SS1")
    check(string_constants.SS2, "\u00C6\u00CEOU\n", "SS2")
    check(string_constants.EE1, "TUV", "EE1")
    check(string_constants.EE2, "TUV", "EE2")
    check(string_constants.XX1, "WXY", "XX1")
    check(string_constants.XX2, "WXY", "XX2")
    check(string_constants.ZS1, "\u0000", "ZS1")
    check(string_constants.ZS2, "\u0000", "ZS2")
    check(string_constants.ES1, "", "ES1")
    check(string_constants.ES2, "", "ES2")
    check(string_constants.QQ1, "\b00! \u00018b00!", "QQ1")
    check(string_constants.QQ2, "\b00! \u00018b00!", "QQ2")

    // Variable forms come through JNI: an embedded null truncates the string there.
    check(string_constants.SS3, "\u00C6\u00CEOU\n", "SS3")
    check(string_constants.EE3, "TUV", "EE3")
    check(string_constants.XX3, "WXY", "XX3")
    check(string_constants.ZS3, "", "ZS3")
    check(string_constants.ES3, "", "ES3")
    check(string_constants.QQ3, "\b00! \u00018b00!", "QQ3")

    // Default argument values mirror the variable (JNI) forms.
    val t = things()
    check(t.defarguments1(), "\u00C6\u00CEOU\n", "defarguments1")
    check(t.defarguments3(), "TUV", "defarguments3")
    check(t.defarguments4(), "WXY", "defarguments4")
    check(t.defarguments5(), "", "defarguments5")
    check(t.defarguments6(), "", "defarguments6")
    check(t.defarguments7(), "\b00! \u00018b00!", "defarguments7")
}

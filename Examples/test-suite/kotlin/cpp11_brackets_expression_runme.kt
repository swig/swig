@file:JvmName("cpp11_brackets_expression_runme")

import cpp11_brackets_expression.*

fun main() {
    try {
        System.loadLibrary("cpp11_brackets_expression")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    var x: Long = Piece.kMaxSize
    x = Piece.SimpleAsYouExpect123
    x = Piece.Just123
    x = cpp11_brackets_expression.kMaxSizeGlobal

    x = cpp11_brackets_expression.kMaxSizeGlobal
    x = cpp11_brackets_expression.global_as_you_expect(123).toLong()
    x = cpp11_brackets_expression.global_one_two_three().toLong()
}

@file:JvmName("cpp11_brackets_expression_runme")

import cpp11_brackets_expression.*

fun main() {
    try {
        System.loadLibrary("cpp11_brackets_expression")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    @Suppress("ASSIGNED_BUT_NEVER_ACCESSED_VARIABLE")
    var x: Long = Piece.kMaxSize
    @Suppress("UNUSED_VALUE")
    x = Piece.SimpleAsYouExpect123
    @Suppress("UNUSED_VALUE")
    x = Piece.Just123
    @Suppress("UNUSED_VALUE")
    x = cpp11_brackets_expression.kMaxSizeGlobal

    @Suppress("UNUSED_VALUE")
    x = cpp11_brackets_expression.kMaxSizeGlobal
    @Suppress("UNUSED_VALUE")
    x = cpp11_brackets_expression.global_as_you_expect(123).toLong()
    @Suppress("UNUSED_VALUE")
    x = cpp11_brackets_expression.global_one_two_three().toLong()
}

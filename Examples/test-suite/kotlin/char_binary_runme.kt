@file:JvmName("char_binary_runme")

import char_binary.*

fun main() {
    try {
        System.loadLibrary("char_binary")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val t = Test()

    val hile = "hile"
    if (t.strlen(hile) != 4L)
        throw RuntimeException("bad multi-arg typemap")

    if (t.ustrlen(hile) != 4L)
        throw RuntimeException("bad multi-arg typemap")

    val hil0 = "hil\u0000"
    if (t.strlen(hil0) != 4L)
        throw RuntimeException("bad multi-arg typemap")

    if (t.ustrlen(hil0) != 4L)
        throw RuntimeException("bad multi-arg typemap")

    // creating a raw char*
    val pc = char_binary.new_pchar(5)
    char_binary.pchar_setitem(pc, 0, 'h')
    char_binary.pchar_setitem(pc, 1, 'o')
    char_binary.pchar_setitem(pc, 2, 'l')
    char_binary.pchar_setitem(pc, 3, 'a')
    char_binary.pchar_setitem(pc, 4, '\u0000')

    char_binary.var_pchar = "hola"
    if (char_binary.var_pchar != "hola")
        throw RuntimeException("bad pointer case")

    char_binary.var_namet = "hola"
    if (char_binary.var_namet != "hola")
        throw RuntimeException("bad pointer case")

    char_binary.delete_pchar(pc)
}

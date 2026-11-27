@file:JvmName("typedef_funcptr_runme")

import typedef_funcptr.*

fun main() {
    try {
        System.loadLibrary("typedef_funcptr")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val a = 100
    val b = 10

    if (typedef_funcptr.do_op(a, b, typedef_funcptr.addf) != 110)
        throw RuntimeException("addf failed")
    if (typedef_funcptr.do_op(a, b, typedef_funcptr.subf) != 90)
        throw RuntimeException("subf failed")

    if (typedef_funcptr.do_op_typedef_int(a, b, typedef_funcptr.addf) != 110)
        throw RuntimeException("addf failed")
    if (typedef_funcptr.do_op_typedef_int(a, b, typedef_funcptr.subf) != 90)
        throw RuntimeException("subf failed")

    if (typedef_funcptr.do_op_typedef_Integer(a, b, typedef_funcptr.addf) != 110)
        throw RuntimeException("addf failed")
    if (typedef_funcptr.do_op_typedef_Integer(a, b, typedef_funcptr.subf) != 90)
        throw RuntimeException("subf failed")
}

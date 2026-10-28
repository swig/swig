@file:JvmName("typedef_classforward_same_name_runme")

import typedef_classforward_same_name.*

fun main() {
    try {
        System.loadLibrary("typedef_classforward_same_name")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val foo = Foo()
    foo.x = 5
    if (typedef_classforward_same_name.extractFoo(foo) != 5)
        throw RuntimeException("unexpected value")

    val boo = Boo()
    boo.x = 5
    if (typedef_classforward_same_name.extractBoo(boo) != 5)
        throw RuntimeException("unexpected value")
}

@file:JvmName("cpp_typedef_runme")

// This is the cpp_typedef runtime testcase. It checks that proxy classes are
// generated for typedef'd types.

import cpp_typedef.*

fun main() {
    try {
        System.loadLibrary("cpp_typedef")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val f = Foo()
    var pbar = f.bar()
    pbar = Foo.sbar()

    val test = Test()
    val unnamed = UnnamedStruct()
    val named = TypedefNamedStruct()

    val unnamed2 = test.test1(unnamed)
    val named2 = test.test2(named)
    val named3 = test.test3(named)
    val named4 = test.test4(named)
}

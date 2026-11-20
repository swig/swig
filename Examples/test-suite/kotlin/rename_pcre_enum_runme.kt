@file:JvmName("rename_pcre_enum_runme")

import rename_pcre_enum.*

fun main() {
    try {
        System.loadLibrary("rename_pcre_enum")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val foo = Foo.First
    if (foo == Foo.Second)
        throw RuntimeException("Enum values should be different")

    // Check that Foo_Max enum element was ignored. These are typesafe enums
    // (plain classes) so values()/ordinal are not available; use swigValue.
    if (Foo.Second.swigValue != Foo.First.swigValue + 1)
        throw RuntimeException("Enum should have 2 elements")

    val bc = BoundaryCondition.MaxMax
    if (bc.swigValue != 2)
        throw RuntimeException("Wrong enum value")

    val c = Colour.red
    if (c == Colour.blue)
        throw RuntimeException("Enum values should be different")
}

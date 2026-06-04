@file:JvmName("template_templated_constructors_runme")

import template_templated_constructors.*

fun main() {
    try {
        System.loadLibrary("template_templated_constructors")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val t1 = TConstructor1(123)
    val t2a = TConstructor2()
    val t2b = TConstructor2(123)

    val tc1 = TClass1Int(123.4)
    val tc2a = TClass2Int()
    val tc2b = TClass2Int(123.4)

    val double_pair = DoublePair(1.1, 2.2)
    val short_pair = ShortPair(0.toShort(), 1.toShort())
    val string_pair = StringPair("10", "11")
    val ip1 = IntPair()
    val ip2 = IntPair(20, 21)
    val ip3 = IntPair(ip1)
    val ip4 = IntPair(short_pair)
    // These next two use IntPair constructors, unlike Python which requires factory function calls
    val ip5 = IntPair(double_pair)
    val ip6 = IntPair(string_pair)
}

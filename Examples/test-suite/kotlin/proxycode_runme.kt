@file:JvmName("proxycode_runme")

import proxycode.*

fun main() {
    try {
        System.loadLibrary("proxycode")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    if (Proxy1().proxycode1(100) != 101)
        throw RuntimeException("Fail")
    if (Proxy2().proxycode2a(100) != 102)
        throw RuntimeException("Fail")
    if (Proxy2().proxycode2b(100) != 102)
        throw RuntimeException("Fail")
    if (Proxy3().proxycode3(100) != 103)
        throw RuntimeException("Fail")

    if (Proxy4().proxycode4(100) != 104)
        throw RuntimeException("Fail")
    if (Proxy4.Proxy4Nested().proxycode4nested(100) != 144)
        throw RuntimeException("Fail")

    if (Proxy5a().proxycode5(100.toShort()) != 100.toShort())
        throw RuntimeException("Fail")
    if (Proxy5b().proxycode5(100) != 100)
        throw RuntimeException("Fail")
    if (Proxy5b().proxycode5(100, 100) != 255)
        throw RuntimeException("Fail")

    val t1: Long = 10
    val t2: Long = 100
    val p = Proxy6().proxyUseT(t1, t2)
    p.useT(t1, t2)
}

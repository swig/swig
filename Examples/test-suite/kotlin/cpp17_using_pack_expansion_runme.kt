@file:JvmName("cpp17_using_pack_expansion_runme")

import cpp17_using_pack_expansion.*

fun main() {
    try {
        System.loadLibrary("cpp17_using_pack_expansion")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Direct call via %template proxy (C++17 pack expansion in a using-declaration).
    val ov = OverloadedIntDouble()
    if (ov.call(7) != "Int:7")
        throw RuntimeException("ov.call(7)")
    if (ov.call(2.5) != "Double:2.500000")
        throw RuntimeException("ov.call(2.5)")

    // std::visit idiom using helper functions.
    if (cpp17_using_pack_expansion.visit_functors_int(7) != "Int:7")
        throw RuntimeException("visit_functors_int(7)")
    if (cpp17_using_pack_expansion.visit_functors_double(2.5) != "Double:2.500000")
        throw RuntimeException("visit_functors_double(2.5)")

    // Pack expansion in a using-declaration with a nested qualifier 'Base<Ts>::operator()...;'.
    val mx = MixedIntDouble()
    if (mx.call(7) != "T:7")
        throw RuntimeException("mx.call(7)")
    if (mx.call(2.5) != "T:2.500000")
        throw RuntimeException("mx.call(2.5)")

    // Empty pack: the using-declaration introduces no names, so the proxy class is constructible
    // but has no inherited call method.
    val emptyOverloaded = OverloadedEmpty()
    val emptyMixed = MixedEmpty()
    for (m in OverloadedEmpty::class.java.declaredMethods) {
        if (m.name == "call")
            throw RuntimeException("OverloadedEmpty unexpectedly exposes call()")
    }
    for (m in MixedEmpty::class.java.declaredMethods) {
        if (m.name == "call")
            throw RuntimeException("MixedEmpty unexpectedly exposes call()")
    }
    emptyOverloaded.delete()
    emptyMixed.delete()

    // Empty pack with member methods either side of the using-decl: the using-decl is removed
    // and before_using()/after_using() remain intact in the proxy.
    val wm = WithMembersEmpty()
    if (wm.before_using() != "before")
        throw RuntimeException("wm.before_using()")
    if (wm.after_using() != "after")
        throw RuntimeException("wm.after_using()")
    for (m in WithMembersEmpty::class.java.declaredMethods) {
        if (m.name == "call")
            throw RuntimeException("WithMembersEmpty unexpectedly exposes call()")
    }
    wm.delete()
}

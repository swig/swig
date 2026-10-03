@file:JvmName("using_method_typedefs_runme")

import using_method_typedefs.*

fun check(actual: String, expected: String) {
    if (actual != expected)
        throw RuntimeException("expected '$expected' but got '$actual'")
}

fun main() {
    try {
        System.loadLibrary("using_method_typedefs")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // A protected base method brought into the derived public interface via a using declaration whose
    // qualifier names the base through various typedef forms (issue #2951 typedef coverage, for members).
    check(UseDirect().testmethod("5"), "Base:5")
    check(UseTypedef().testmethod("5"), "Base:5")
    check(UseTypedefChain().testmethod("5"), "Base:5")
    check(UseTemplateTypedef().testmethod("5"), "TBase:5")
    check(UseTemplateArgTypedef().testmethod("5"), "TBase:5")
    check(UseQualified().testmethod("5"), "Ns:5")
    check(UseNsChain().testmethod("5"), "Ns:5")
}

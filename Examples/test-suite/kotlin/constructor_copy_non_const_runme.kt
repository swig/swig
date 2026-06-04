@file:JvmName("constructor_copy_non_const_runme")

import constructor_copy_non_const.*

fun main() {
    try {
        System.loadLibrary("constructor_copy_non_const")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    run {
        val ccb2 = CCBase2(CCBase2())
        val ccd = CCDerived(CCDerived())
        val ccmd = CCMoreDerived(CCMoreDerived())
        val ccmd2 = CCMoreDerived2(CCMoreDerived2())
        val ccmmd2 = CCMoreMoreDerived2(CCMoreMoreDerived2())
    }
    run {
        // no copy ctor CCProtectedBase2
        val ccd = CCProtectedDerived(CCProtectedDerived())
        val ccmd = CCProtectedMoreDerived(CCProtectedMoreDerived())
        val ccmd2 = CCProtectedMoreDerived2(CCProtectedMoreDerived2())
        val ccmmd2 = CCProtectedMoreMoreDerived2(CCProtectedMoreMoreDerived2())
    }
}

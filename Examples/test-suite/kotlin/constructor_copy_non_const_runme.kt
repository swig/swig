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
        @Suppress("UNUSED_VARIABLE")
        val ccb2 = CCBase2(CCBase2())
        @Suppress("UNUSED_VARIABLE")
        val ccd = CCDerived(CCDerived())
        @Suppress("UNUSED_VARIABLE")
        val ccmd = CCMoreDerived(CCMoreDerived())
        @Suppress("UNUSED_VARIABLE")
        val ccmd2 = CCMoreDerived2(CCMoreDerived2())
        @Suppress("UNUSED_VARIABLE")
        val ccmmd2 = CCMoreMoreDerived2(CCMoreMoreDerived2())
    }
    run {
        // no copy ctor CCProtectedBase2
        @Suppress("UNUSED_VARIABLE")
        val ccd = CCProtectedDerived(CCProtectedDerived())
        @Suppress("UNUSED_VARIABLE")
        val ccmd = CCProtectedMoreDerived(CCProtectedMoreDerived())
        @Suppress("UNUSED_VARIABLE")
        val ccmd2 = CCProtectedMoreDerived2(CCProtectedMoreDerived2())
        @Suppress("UNUSED_VARIABLE")
        val ccmmd2 = CCProtectedMoreMoreDerived2(CCProtectedMoreMoreDerived2())
    }
}

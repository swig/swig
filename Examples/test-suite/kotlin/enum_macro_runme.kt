@file:JvmName("enum_macro_runme")

import enum_macro.*

fun main() {
    try {
        System.loadLibrary("enum_macro")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    run {
        @Suppress("VARIABLE_WITH_REDUNDANT_INITIALIZER")
        var a = Greeks1.alpha1
        @Suppress("UNUSED_VALUE")
        a = Greeks1.beta1
        a = Greeks1.theta1
        if (a.swigValue != 3) throw RuntimeException("Greeks1")
    }
    run {
        @Suppress("VARIABLE_WITH_REDUNDANT_INITIALIZER")
        var a = Greeks2.alpha2
        @Suppress("UNUSED_VALUE")
        a = Greeks2.beta2
        a = Greeks2.theta2
        if (a.swigValue != 4) throw RuntimeException("Greeks2")
    }
    run {
        @Suppress("VARIABLE_WITH_REDUNDANT_INITIALIZER")
        var a = Greeks3.alpha3
        @Suppress("UNUSED_VALUE")
        a = Greeks3.beta3
        a = Greeks3.theta3
        if (a.swigValue != 2) throw RuntimeException("Greeks3")
    }
    run {
        @Suppress("VARIABLE_WITH_REDUNDANT_INITIALIZER")
        var a = Greeks4.alpha4
        @Suppress("UNUSED_VALUE")
        a = Greeks4.beta4
        a = Greeks4.theta4
        if (a.swigValue != 6) throw RuntimeException("Greeks4")
    }
    run {
        @Suppress("VARIABLE_WITH_REDUNDANT_INITIALIZER")
        var a = Greeks5.alpha5
        a = Greeks5.beta5
        if (a.swigValue != 1) throw RuntimeException("Greeks5")
    }
    run {
        @Suppress("VARIABLE_WITH_REDUNDANT_INITIALIZER")
        var a = Greeks6.alpha6
        a = Greeks6.beta6
        if (a.swigValue != 1) throw RuntimeException("Greeks6")
    }
    run {
        @Suppress("VARIABLE_WITH_REDUNDANT_INITIALIZER")
        var a = Greeks7.alpha7
        a = Greeks7.beta7
        if (a.swigValue != 1) throw RuntimeException("Greeks7")
    }
    run {
        val a = Greeks8.theta8
        if (a.swigValue != 0) throw RuntimeException("Greeks8")
    }
    run {
        val a = Greeks9.theta9
        if (a.swigValue != 0) throw RuntimeException("Greeks9")
    }
    run {
        val a = Greeks10.theta10
        if (a.swigValue != 0) throw RuntimeException("Greeks10")
    }
    run {
        val a = Greeks11.theta11
        if (a.swigValue != 0) throw RuntimeException("Greeks11")
    }
    run {
        val a = Greeks12.theta12
        if (a.swigValue != 0) throw RuntimeException("Greeks12")
    }
    run {
        @Suppress("UNUSED_VARIABLE")
        val a: Greeks13? = null
    }
    run {
        @Suppress("VARIABLE_WITH_REDUNDANT_INITIALIZER")
        var a = Greeks15.alpha15
        @Suppress("UNUSED_VALUE")
        a = Greeks15.beta15
        @Suppress("UNUSED_VALUE")
        a = Greeks15.theta15
        a = Greeks15.delta15
        if (a.swigValue != 153) throw RuntimeException("Greeks15")
    }
    run {
        @Suppress("VARIABLE_WITH_REDUNDANT_INITIALIZER")
        var a = Greeks16.alpha16
        @Suppress("UNUSED_VALUE")
        a = Greeks16.beta16
        @Suppress("UNUSED_VALUE")
        a = Greeks16.theta16
        @Suppress("UNUSED_VALUE")
        a = Greeks16.delta16
        if (a.swigValue != 163) throw RuntimeException("Greeks16")
    }
    run {
        @Suppress("VARIABLE_WITH_REDUNDANT_INITIALIZER")
        var a = Greeks17.alpha17
        @Suppress("UNUSED_VALUE")
        a = Greeks17.beta17
        @Suppress("UNUSED_VALUE")
        a = Greeks17.theta17
        @Suppress("UNUSED_VALUE")
        a = Greeks17.delta17
        if (a.swigValue != 173) throw RuntimeException("Greeks17")
    }
}

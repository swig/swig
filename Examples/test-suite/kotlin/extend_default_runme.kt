@file:JvmName("extend_default_runme")

import extend_default.*

fun main() {
    try {
        System.loadLibrary("extend_default")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // %extend before the class definition
    run {
        var ex = Before()
        if (ex.i.toDouble() != -1.0 || ex.d != -1.0)
            throw RuntimeException("Before constructor 1 failed")

        ex = Before(10)
        if (ex.i.toDouble() != 10.0 || ex.d != -1.0)
            throw RuntimeException("Before constructor 2 failed")

        ex = Before(20, 30.0)
        if (ex.i != 20 || ex.d != 30.0)
            throw RuntimeException("Before constructor 3 failed")
    }
    run {
        val ex = Before()
        if (ex.AddedMethod() != -2.0)
            throw RuntimeException("Before AddedMethod 1 failed")
        if (ex.AddedMethod(-2) != -3.0)
            throw RuntimeException("Before AddedMethod 2 failed")
        if (ex.AddedMethod(-10, -10.0) != -20.0)
            throw RuntimeException("Before AddedMethod 3 failed")
    }
    run {
        if (Before.AddedStaticMethod() != -2.0)
            throw RuntimeException("Before AddedStaticMethod 1 failed")
        if (Before.AddedStaticMethod(-2) != -3.0)
            throw RuntimeException("Before AddedStaticMethod 2 failed")
        if (Before.AddedStaticMethod(-10, -10.0) != -20.0)
            throw RuntimeException("Before AddedStaticMethod 3 failed")
    }

    // %extend after the class definition
    run {
        var ex = After()
        if (ex.i.toDouble() != -1.0 || ex.d != -1.0)
            throw RuntimeException("After constructor 1 failed")

        ex = After(10)
        if (ex.i.toDouble() != 10.0 || ex.d != -1.0)
            throw RuntimeException("After constructor 2 failed")

        ex = After(20, 30.0)
        if (ex.i != 20 || ex.d != 30.0)
            throw RuntimeException("After constructor 3 failed")
    }
    run {
        val ex = After()
        if (ex.AddedMethod() != -2.0)
            throw RuntimeException("After AddedMethod 1 failed")
        if (ex.AddedMethod(-2) != -3.0)
            throw RuntimeException("After AddedMethod 2 failed")
        if (ex.AddedMethod(-10, -10.0) != -20.0)
            throw RuntimeException("After AddedMethod 3 failed")
    }
    run {
        if (After.AddedStaticMethod() != -2.0)
            throw RuntimeException("After AddedStaticMethod 1 failed")
        if (After.AddedStaticMethod(-2) != -3.0)
            throw RuntimeException("After AddedStaticMethod 2 failed")
        if (After.AddedStaticMethod(-10, -10.0) != -20.0)
            throw RuntimeException("After AddedStaticMethod 3 failed")
    }

    // %extend before the class definition - with overloading and default args
    run {
        var ex = OverBefore()
        if (ex.i.toDouble() != -1.0 || ex.d != -1.0)
            throw RuntimeException("OverBefore constructor 1 failed")

        ex = OverBefore(10)
        if (ex.i.toDouble() != 10.0 || ex.d != -1.0)
            throw RuntimeException("OverBefore constructor 2 failed")

        ex = OverBefore(20, 30.0)
        if (ex.i != 20 || ex.d != 30.0)
            throw RuntimeException("OverBefore constructor 3 failed")
    }
    run {
        val ex = OverBefore()
        if (ex.AddedMethod() != -2.0)
            throw RuntimeException("OverBefore AddedMethod 1 failed")
        if (ex.AddedMethod(-2) != -3.0)
            throw RuntimeException("OverBefore AddedMethod 2 failed")
        if (ex.AddedMethod(-10, -10.0) != -20.0)
            throw RuntimeException("OverBefore AddedMethod 3 failed")
    }
    run {
        if (OverBefore.AddedStaticMethod() != -2.0)
            throw RuntimeException("OverBefore AddedStaticMethod 1 failed")
        if (OverBefore.AddedStaticMethod(-2) != -3.0)
            throw RuntimeException("OverBefore AddedStaticMethod 2 failed")
        if (OverBefore.AddedStaticMethod(-10, -10.0) != -20.0)
            throw RuntimeException("OverBefore AddedStaticMethod 3 failed")
    }
    run {
        var ex = OverBefore("hello")
        if (ex.i.toDouble() != -2.0 || ex.d != -2.0)
            throw RuntimeException("OverBefore overload constructor 1 failed")

        ex = OverBefore("hello", 10)
        if (ex.i.toDouble() != 10.0 || ex.d != -2.0)
            throw RuntimeException("OverBefore overload constructor 2 failed")

        ex = OverBefore("hello", 20, 30.0)
        if (ex.i != 20 || ex.d != 30.0)
            throw RuntimeException("OverBefore overload constructor 3 failed")
    }
    run {
        val ex = OverBefore("hello")
        if (ex.AddedMethod("hello") != -2.0)
            throw RuntimeException("OverBefore overload AddedMethod 1 failed")
        if (ex.AddedMethod("hello", -2) != -3.0)
            throw RuntimeException("OverBefore overload AddedMethod 2 failed")
        if (ex.AddedMethod("hello", -10, -10.0) != -20.0)
            throw RuntimeException("OverBefore overload AddedMethod 3 failed")
    }
    run {
        if (OverBefore.AddedStaticMethod("hello") != -2.0)
            throw RuntimeException("OverBefore overload AddedStaticMethod 1 failed")
        if (OverBefore.AddedStaticMethod("hello", -2) != -3.0)
            throw RuntimeException("OverBefore overload AddedStaticMethod 2 failed")
        if (OverBefore.AddedStaticMethod("hello", -10, -10.0) != -20.0)
            throw RuntimeException("OverBefore overload AddedStaticMethod 3 failed")
    }

    // %extend after the class definition - with overloading and default args
    run {
        var ex = OverAfter()
        if (ex.i.toDouble() != -1.0 || ex.d != -1.0)
            throw RuntimeException("OverAfter constructor 1 failed")

        ex = OverAfter(10)
        if (ex.i.toDouble() != 10.0 || ex.d != -1.0)
            throw RuntimeException("OverAfter constructor 2 failed")

        ex = OverAfter(20, 30.0)
        if (ex.i != 20 || ex.d != 30.0)
            throw RuntimeException("OverAfter constructor 3 failed")
    }
    run {
        val ex = OverAfter()
        if (ex.AddedMethod() != -2.0)
            throw RuntimeException("OverAfter AddedMethod 1 failed")
        if (ex.AddedMethod(-2) != -3.0)
            throw RuntimeException("OverAfter AddedMethod 2 failed")
        if (ex.AddedMethod(-10, -10.0) != -20.0)
            throw RuntimeException("OverAfter AddedMethod 3 failed")
    }
    run {
        if (OverAfter.AddedStaticMethod() != -2.0)
            throw RuntimeException("OverAfter AddedStaticMethod 1 failed")
        if (OverAfter.AddedStaticMethod(-2) != -3.0)
            throw RuntimeException("OverAfter AddedStaticMethod 2 failed")
        if (OverAfter.AddedStaticMethod(-10, -10.0) != -20.0)
            throw RuntimeException("OverAfter AddedStaticMethod 3 failed")
    }
    run {
        var ex = OverAfter("hello")
        if (ex.i.toDouble() != -2.0 || ex.d != -2.0)
            throw RuntimeException("OverAfter overload constructor 1 failed")

        ex = OverAfter("hello", 10)
        if (ex.i.toDouble() != 10.0 || ex.d != -2.0)
            throw RuntimeException("OverAfter overload constructor 2 failed")

        ex = OverAfter("hello", 20, 30.0)
        if (ex.i != 20 || ex.d != 30.0)
            throw RuntimeException("OverAfter overload constructor 3 failed")
    }
    run {
        val ex = OverAfter("hello")
        if (ex.AddedMethod("hello") != -2.0)
            throw RuntimeException("OverAfter overload AddedMethod 1 failed")
        if (ex.AddedMethod("hello", -2) != -3.0)
            throw RuntimeException("OverAfter overload AddedMethod 2 failed")
        if (ex.AddedMethod("hello", -10, -10.0) != -20.0)
            throw RuntimeException("OverAfter overload AddedMethod 3 failed")
    }
    run {
        if (OverAfter.AddedStaticMethod("hello") != -2.0)
            throw RuntimeException("OverAfter overload AddedStaticMethod 1 failed")
        if (OverAfter.AddedStaticMethod("hello", -2) != -3.0)
            throw RuntimeException("OverAfter overload AddedStaticMethod 2 failed")
        if (OverAfter.AddedStaticMethod("hello", -10, -10.0) != -20.0)
            throw RuntimeException("OverAfter overload AddedStaticMethod 3 failed")
    }

    // Override
    run {
        val o = Override()

        if (o.over() != -1)
            throw RuntimeException("override test 1 failed")
        if (o.over(10) != 10 * 10)
            throw RuntimeException("override test 2 failed")

        if (o.ride() != -1)
            throw RuntimeException("override test 3 failed")
        if (o.ride(10) != 10)
            throw RuntimeException("override test 4 failed")

        if (o.overload() != -10)
            throw RuntimeException("override test 5 failed")
        if (o.overload(10) != 10 * 10)
            throw RuntimeException("override test 6 failed")
    }
}

@file:JvmName("director_primitives_runme")

/*
  This test program shows a Kotlin class KotlinDerived inheriting from Base. Three types of classes are created
  and the virtual methods called to demonstrate:
  1) Wide variety of primitive types
  2) Calling methods with zero, one or more parameters
  3) Director methods that are not overridden in Kotlin
  4) Director classes that are not overridden at all in Kotlin, ie non-director behaviour is as expected for director classes
  5) Inheritance hierarchy using director methods
  6) Return types working as well as parameters

  The Caller class is a tester class, which calls the virtual functions from C++.
*/

import director_primitives.*

class KotlinDerived(dd: Double) : Base(dd) {
    override fun NoParmsMethod() {
        if (director_primitives.PrintDebug) println("KotlinDerived - NoParmsMethod()")
    }

    override fun BoolMethod(x: Boolean): Boolean {
        if (director_primitives.PrintDebug) println("KotlinDerived - BoolMethod($x)")
        return x
    }

    override fun IntMethod(x: Int): Int {
        if (director_primitives.PrintDebug) println("KotlinDerived - IntMethod($x)")
        return x
    }

    override fun UIntMethod(x: Long): Long {
        if (director_primitives.PrintDebug) println("KotlinDerived - UIntMethod($x)")
        return x
    }

    override fun FloatMethod(x: Float): Float {
        if (director_primitives.PrintDebug) println("KotlinDerived - FloatMethod($x)")
        return x
    }

    override fun CharPtrMethod(x: String?): String? {
        if (director_primitives.PrintDebug) println("KotlinDerived - CharPtrMethod($x)")
        return x
    }

    override fun ConstCharPtrMethod(x: String?): String? {
        if (director_primitives.PrintDebug) println("KotlinDerived - ConstCharPtrMethod($x)")
        return x
    }

    override fun EnumMethod(x: HShadowMode): HShadowMode {
        if (director_primitives.PrintDebug) println("KotlinDerived - EnumMethod($x)")
        return x
    }

    override fun ManyParmsMethod(b: Boolean, i: Int, u: Long, f: Float, c: String?, cc: String?, h: HShadowMode) {
        if (director_primitives.PrintDebug) println("KotlinDerived - ManyParmsMethod($b, $i, $u, $f, $c, $cc, $h")
    }
}

fun makeCalls(myCaller: Caller, myBase: Base) {
    myCaller.set(myBase)

    myCaller.NoParmsMethodCall()
    if (myCaller.BoolMethodCall(true) != true) throw RuntimeException("failed")
    if (myCaller.BoolMethodCall(false) != false) throw RuntimeException("failed")
    if (myCaller.IntMethodCall(-123) != -123) throw RuntimeException("failed")
    if (myCaller.UIntMethodCall(123) != 123L) throw RuntimeException("failed")
    if (myCaller.FloatMethodCall(-123.456f) != -123.456f) throw RuntimeException("failed")
    if (myCaller.CharPtrMethodCall("test string") != "test string") throw RuntimeException("failed")
    if (myCaller.ConstCharPtrMethodCall("another string") != "another string") throw RuntimeException("failed")
    if (myCaller.EnumMethodCall(HShadowMode.HShadowHard) != HShadowMode.HShadowHard) throw RuntimeException("failed")
    myCaller.ManyParmsMethodCall(true, -123, 123, 123.456f, "test string", "another string", HShadowMode.HShadowHard)
    myCaller.NotOverriddenMethodCall()

    myCaller.reset()
}

fun run() {
    if (director_primitives.PrintDebug) println("------------ Start ------------ ")

    val myCaller = Caller()

    // test C++ base class
    run {
        val myBase = Base(100.0)
        makeCalls(myCaller, myBase)
        myBase.delete()
    }

    if (director_primitives.PrintDebug) println("--------------------------------")

    // test vanilla C++ wrapped derived class
    run {
        val myBase: Base = Derived(200.0)
        makeCalls(myCaller, myBase)
        myBase.delete()
    }

    if (director_primitives.PrintDebug) println("--------------------------------")

    // test director / Kotlin derived class
    run {
        val myBase: Base = KotlinDerived(300.0)
        makeCalls(myCaller, myBase)
        myBase.delete()
    }

    if (director_primitives.PrintDebug) println("------------ Finish ------------ ")
}

fun main() {
    try {
        System.loadLibrary("director_primitives")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    run()
}

@file:JvmName("director_classes_runme")

/*
This test demonstrates director classes when the types are classes.
Shown are virtual function calls which use classes passed by Value,
Reference and Pointer as both parameters and return values.
*/

import director_classes.*

class JavaDerived(dd: Double) : Base(dd) {
    override fun Val(x: DoubleHolder): DoubleHolder {
        if (director_classes.PrintDebug) System.out.println("JavaDerived - Val(" + x._val + ")")
        return x
    }
    override fun Ref(x: DoubleHolder): DoubleHolder {
        if (director_classes.PrintDebug) System.out.println("JavaDerived - Ref(" + x._val + ")")
        return x
    }
    override fun Ptr(x: DoubleHolder?): DoubleHolder? {
        if (director_classes.PrintDebug) System.out.println("JavaDerived - Ptr(" + x!!._val + ")")
        return x
    }
    override fun ConstPtrRef(cprx: DoubleHolder?): DoubleHolder? {
        if (director_classes.PrintDebug) System.out.println("JavaDerived - ConstPtrRef(" + cprx!!._val + ")")
        return cprx
    }
    override fun FullyOverloaded(x: Int): String {
        if (director_classes.PrintDebug) System.out.println("JavaDerived - FullyOverloaded(int " + x + ")")
        return "JavaDerived::FullyOverloaded(int)"
    }
    override fun FullyOverloaded(x: Boolean): String {
        if (director_classes.PrintDebug) System.out.println("JavaDerived - FullyOverloaded(bool " + x + ")")
        return "JavaDerived::FullyOverloaded(bool)"
    }
    // Note no SemiOverloaded(bool x) method
    override fun SemiOverloaded(x: Int): String {
        val ret = "JavaDerived::SemiOverloaded(int)"
        if (director_classes.PrintDebug) System.out.println("JavaDerived - SemiOverloaded(" + x + ")")
        return ret
    }
    override fun DefaultParms(x: Int, y: Double): String {
        val ret = "JavaDerived::DefaultParms(int, double)"
        if (director_classes.PrintDebug) System.out.println("JavaDerived - DefaultParms(" + x + ", " + y + ")")
        return ret
    }
    override fun DefaultParms(x: Int): String {
        if (director_classes.PrintDebug) System.out.println("JavaDerived - DefaultParms(" + x + ")")
        return DefaultParms(x, 1.125)
    }
}

// Same as Class.getSimpleName()
fun getSimpleName(klass: Class<*>): String {
    val fullName = klass.getName()
    val packag = klass.getPackage()
    val simpleName: String
    if (packag != null)
        simpleName = fullName.replace(Regex(Regex.escape(packag.getName()) + "\\."), "")
    else
        simpleName = fullName
    return simpleName
}

fun makeCalls(myCaller: Caller, myBase: Base) {
    val baseSimpleName = getSimpleName(myBase.javaClass)

    myCaller.set(myBase)

    val dh = DoubleHolder(444.555)

    // Class pointer, reference and pass by value tests
    if (myCaller.ValCall(dh)._val != dh._val) throw RuntimeException("failed")
    if (myCaller.RefCall(dh)._val != dh._val) throw RuntimeException("failed")
    if (myCaller.PtrCall(dh)!!._val != dh._val) throw RuntimeException("failed")
    if (myCaller.ConstPtrRefCall(dh)!!._val != dh._val) throw RuntimeException("failed")

    // Fully overloaded method test (all methods in base class are overloaded)
    if (myCaller.FullyOverloadedCall(10) != baseSimpleName + "::FullyOverloaded(int)") {
        System.out.println(myCaller.FullyOverloadedCall(10) + "----" + (baseSimpleName + "::FullyOverloaded(int)"))
        throw RuntimeException("failed")
    }
    if (myCaller.FullyOverloadedCall(true) != baseSimpleName + "::FullyOverloaded(bool)") throw RuntimeException("failed")

    // Semi overloaded method test (some methods in base class are overloaded)
    if (myCaller.SemiOverloadedCall(-678) != baseSimpleName + "::SemiOverloaded(int)") throw RuntimeException("failed")
    if (myCaller.SemiOverloadedCall(true) != "Base" + "::SemiOverloaded(bool)") throw RuntimeException("failed")

    // Default parameters methods test
    if (myCaller.DefaultParmsCall(10, 2.25) != baseSimpleName + "::DefaultParms(int, double)") throw RuntimeException("failed")
    if (myBase is JavaDerived) { // special handling for target language derived classes
        if (myCaller.DefaultParmsCall(10) != baseSimpleName + "::DefaultParms(int, double)") throw RuntimeException("failed")
    } else {
        if (myCaller.DefaultParmsCall(10) != baseSimpleName + "::DefaultParms(int)") throw RuntimeException("failed")
    }

    myCaller.reset()
}

fun main() {
    try {
        System.loadLibrary("director_classes")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    if (director_classes.PrintDebug) System.out.println("------------ Start ------------")

    val myCaller = Caller()

    // test C++ base class
    run {
        val myBase = Base(100.0)
        makeCalls(myCaller, myBase)
        myBase.delete()
    }

    if (director_classes.PrintDebug) System.out.println("--------------------------------")

    // test vanilla C++ wrapped derived class
    run {
        val myBase: Base = Derived(200.0)
        makeCalls(myCaller, myBase)
        myBase.delete()
    }

    if (director_classes.PrintDebug) System.out.println("--------------------------------")

    // test director / target language derived class
    run {
        val myBase: Base = JavaDerived(300.0)
        makeCalls(myCaller, myBase)
        myBase.delete()
    }

    if (director_classes.PrintDebug) System.out.println("------------ Finish ------------")
}

@file:JvmName("extend_constructor_destructor_runme")

import extend_constructor_destructor.*

fun checkGlobal(value: Int) {
    val global = extend_constructor_destructor.globalVar
    if (global != value)
        throw RuntimeException("global value incorrect. Expected: " + value + " got: " + global)
}

fun main() {
    try {
        System.loadLibrary("extend_constructor_destructor")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val a = AStruct(10)
    checkGlobal(10)
    val b = BStruct(20)
    checkGlobal(20)
    val c = CStruct(30)
    checkGlobal(30)
    val d = DStruct(40)
    checkGlobal(40)
    val e = EStruct(50)
    checkGlobal(50)
    val f = FStruct(60)
    checkGlobal(60)
    val g = GStruct(70)
    checkGlobal(70)

    a.delete()
    checkGlobal(-10)
    b.delete()
    checkGlobal(-20)
    c.delete()
    checkGlobal(-30)
    d.delete()
    checkGlobal(-40)
    e.delete()
    checkGlobal(-50)
    f.delete()
    checkGlobal(-60)
    g.delete()
    checkGlobal(-70)
}

@file:JvmName("global_namespace_runme")

import global_namespace.*

fun main() {
    try {
        System.loadLibrary("global_namespace")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    var k1 = Klass1()
    var k2 = Klass2()
    var k3 = Klass3()
    var k4 = Klass4()
    var k5 = Klass5()
    var k6 = Klass6()
    var k7 = Klass7()

    KlassMethods.methodA(k1, k2, k3, k4, k5, k6, k7)
    KlassMethods.methodB(k1, k2, k3, k4, k5, k6, k7)

    k1 = global_namespace.getKlass1A()
    k2 = global_namespace.getKlass2A()
    k3 = global_namespace.getKlass3A()
    k4 = global_namespace.getKlass4A()
    k5 = global_namespace.getKlass5A()
    k6 = global_namespace.getKlass6A()
    k7 = global_namespace.getKlass7A()

    KlassMethods.methodA(k1, k2, k3, k4, k5, k6, k7)
    KlassMethods.methodB(k1, k2, k3, k4, k5, k6, k7)

    k1 = global_namespace.getKlass1B()
    k2 = global_namespace.getKlass2B()
    k3 = global_namespace.getKlass3B()
    k4 = global_namespace.getKlass4B()
    k5 = global_namespace.getKlass5B()
    k6 = global_namespace.getKlass6B()
    k7 = global_namespace.getKlass7B()

    KlassMethods.methodA(k1, k2, k3, k4, k5, k6, k7)
    KlassMethods.methodB(k1, k2, k3, k4, k5, k6, k7)

    XYZMethods.methodA(XYZ1(), XYZ2(), XYZ3(), XYZ4(), XYZ5(), XYZ6(), XYZ7())
    XYZMethods.methodB(XYZ1(), XYZ2(), XYZ3(), XYZ4(), XYZ5(), XYZ6(), XYZ7())

    TheEnumMethods.methodA(TheEnum1.theenum1, TheEnum2.theenum2, TheEnum3.theenum3)
    TheEnumMethods.methodA(TheEnum1.theenum1, TheEnum2.theenum2, TheEnum3.theenum3)
}

@file:JvmName("rename1_runme")

import rename1.*

fun main() {
    try {
        System.loadLibrary("rename1")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    run {
        val xyz = XYZInt()
        val notxyz = NotXYZInt()
        xyz.opIntPtrA()
        xyz.opIntPtrB()
        xyz.opAnother2()
        xyz.opT2()
        xyz.tMethod2(0)
        xyz.tMethodNotXYZ2(notxyz)
        xyz.opNotXYZ2()
    }
    run {
        val xyz = XYZDouble()
        val notxyz = NotXYZDouble()
        xyz.opIntPtrA()
        xyz.opIntPtrB()
        xyz.opAnother1()
        xyz.opT1()
        xyz.tMethod1(0.0)
        xyz.tMethodNotXYZ1(notxyz)
        xyz.opNotXYZ1()
    }
    run {
        val xyz = XYZKlass()
        val notxyz = NotXYZKlass()
        xyz.opIntPtrA()
        xyz.opIntPtrB()
        xyz.opAnother3()
        xyz.opT3()
        xyz.tMethod3(Klass())
        xyz.tMethodNotXYZ3(notxyz)
        xyz.opNotXYZ3()
    }
    run {
        val xyz = XYZEnu()
        val notxyz = NotXYZEnu()
        xyz.opIntPtrA()
        xyz.opIntPtrB()
        xyz.opAnother4()
        xyz.opT4()
        xyz.tMethod4(Enu.En1)
        xyz.tMethodNotXYZ4(notxyz)
        xyz.opNotXYZ4()
    }
    run {
        val abc = ABC()
        abc.methodABC(abc)
        var k = Klass()
        abc.methodKlass(k)
        val a = abc.opABC()
        k = abc.opKlass()
    }
}

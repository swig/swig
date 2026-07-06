@file:JvmName("virtual_poly_runme")

import virtual_poly.*

fun main() {
    try {
        System.loadLibrary("virtual_poly")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val d = NDouble(3.5)
    val i = NInt(2)

    //
    // Unlike C++, we have to downcast instead.
    //
    val dc = d.copy() as NDouble
    val ic = i.copy() as NInt

    val ddc = NDouble.narrow(dc)
    val dic = NInt.narrow(ic)

    virtual_poly.incr(ic)
    if ((i.get() + 1) != ic.get())
        throw RuntimeException("incr test failed")

    //
    // Checking a pure user downcast
    //
    val n1 = d.copy()
    val n2 = d.nnumber()
    val dn1 = NDouble.narrow(n1)!!
    val dn2 = NDouble.narrow(n2)!!

    if (dn1.get() != dn2.get())
        throw RuntimeException("copy/narrow test failed")

    //
    // Checking the ref polymorphic case
    //
    val nr = d.ref_this()
    val dr1 = NDouble.narrow(nr)!!
    val dr2 = d.ref_this() as NDouble
    if (dr1.get() != dr2.get())
        throw RuntimeException("copy/narrow test failed")
}

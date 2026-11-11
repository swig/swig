@file:JvmName("rname_runme")

import rname.*

fun main() {
    try {
        System.loadLibrary("rname")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    rname.foo_i(10)
    rname.foo_d(10.0)
    rname.foo_s(10.toShort())
    rname.foo(10L)

    val bar = Bar()
    bar.foo_i(10)
    bar.foo_d(10.0)
    bar.foo(10.toShort())
    bar.foo_u(10L)

    val base = RenamedBase()
    base.fn1(base, base, base)
    if (base.newname(10.0) != "Base")
        throw RuntimeException("base.newname")

    val derived = RenamedDerived()
    derived.Xfunc(base, base, base)
    if (derived.newname(10.0) != "Derived")
        throw RuntimeException("derived.newname")
}

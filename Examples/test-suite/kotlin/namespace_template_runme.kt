@file:JvmName("namespace_template_runme")

import namespace_template.*

fun main() {
    try {
        System.loadLibrary("namespace_template")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val vc = vectorchar()
    val vs = vectorshort()
    val vi = vectorint()
    val vl = vectorlong()

    vc.blah(10.toChar())
    vs.blah(10.toShort())
    vi.blah(10)
    vl.blah(10)

    vc.vectoruse(vc, vc)
    vs.vectoruse(vs, vs)
    vi.vectoruse(vi, vi)
    vl.vectoruse(vl, vl)
}

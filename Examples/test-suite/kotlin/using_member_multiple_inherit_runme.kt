@file:JvmName("using_member_multiple_inherit_runme")

import using_member_multiple_inherit.*

fun main() {
    try {
        System.loadLibrary("using_member_multiple_inherit")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Single inheritance three deep, only using declarations
    val s3 = Susing3()
    s3.usingmethod(11)

    // Single inheritance three deep, overload using and methods
    val u3 = Using3()
    u3.usingmethod(11)
    u3.usingmethod(11, 22)
    u3.usingmethod(11, 22, 33)

    val m3 = Musing3()
    m3.usingmethod(11)
    m3.usingmethod(11, 22)
    m3.usingmethod(11, 22, 33)

    val d3 = Dusing3()
    d3.usingmethod(11)
    d3.usingmethod(11, 22)

    // Multiple inheritance, multiple using declarations
    val ma = MultMiddleA()
    ma.multmethod(123)
    ma.multmethod("hi")
    ma.multmethod(123, 234)

    val mb = MultBottomB()
    mb.multmethod(123)
    mb.multmethod("hi")
    mb.multmethod(123, 234)
    mb.multmethod(123, 345, 567)

    // Multiple inheritance, with no override on parent class.
    val vu = Vusing2()
    vu.usingmethod(3)
    vu.usingmethod("hi")
}

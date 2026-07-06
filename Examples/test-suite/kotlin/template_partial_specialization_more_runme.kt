@file:JvmName("template_partial_specialization_more_runme")

import template_partial_specialization_more.*

fun main() {
    try {
        System.loadLibrary("template_partial_specialization_more")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // (1)
    var vi = VectInt()
    val num = FooVectIntDouble().partially_specialized(222)
    FooShortPtrDouble().pointer_specialize(0.toShort())
    vi = FooVectVectInt().partially_specialized(vi)

    // (2)
    HeyInts().special_hey()

    // (3)
    XX1().special1()
    XX2().special2()
    XX3().special3()

    // (4)
    PartiallerPrimary().primary(0.toShort(), 0.toShort())
    PartiallerSpecial().special(PlainStruct(), 999, true)

    // (5)
    LystDouble().primary(11.1, AllocatorDouble())
    LystShort().primary(0.toShort(), AllocatorShort())
    LystPlainStructPtr().specialized1(PlainStruct(), AllocatorPlainStructPtr())
    LystDoublePtrPtr().specialized2(22.2, null as SWIGTYPE_p_p_double?)
    LystConstIntRef().specialized3(100)
    LystConstStringRef().specialized3("hello")

    // (6)
    val d = SpecDoubleInt()
    val i = SpecStringInt()
    d.spec_specialized(12.3)
    i.spec_specialized("hi")
    template_partial_specialization_more.UseSpec1(d, d)
    template_partial_specialization_more.UseSpec2(i, i)
}

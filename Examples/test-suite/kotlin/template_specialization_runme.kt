@file:JvmName("template_specialization_runme")

import template_specialization.*

fun main() {
    try {
        System.loadLibrary("template_specialization")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val ufd = UnaryFunction_double()
    ufd.negate()

    val ufb = UnaryFunction_bool()
    ufb.foo(ufb)
    ufb.not1()

    val osi = OnlySpecialized_int()
    osi.bar(osi)

    // Type wrapper class not proxy class is returned as primary template definition is not seen by SWIG
    val osd: SWIGTYPE_p_vfncs__OnlySpecializedT_double_t? = template_specialization.factory(null)
}

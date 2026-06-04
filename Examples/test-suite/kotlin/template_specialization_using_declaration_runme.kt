@file:JvmName("template_specialization_using_declaration_runme")

import template_specialization_using_declaration.*

fun main() {
    try {
        System.loadLibrary("template_specialization_using_declaration")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val cc = ConcreteClass(11)

    // Base template tests
    val bs = BaseTemplateString()
    bs.method_primary("hi")

    val cs = BaseTemplateConcreteClass()
    cs.method_specialization(cc)

    val bi = BaseTemplateInt()
    bi.method_partial_specialization(22)

    // Derived template tests
    val ds = DerivedTemplateString()
    ds.method_primary("hi")
    ds.method_primary_derived("hi")
    ds.method_primary_hidden("hi")

    val dc = DerivedTemplateConcreteClass()
    dc.method_specialization(cc)
    dc.method_specialization_derived(cc)
    dc.method_specialization_hidden(cc)

    val di = DerivedTemplateInt()
    di.method_partial_specialization(22)
    di.method_partial_specialization_derived(22)
    di.method_partial_specialization_hidden(22)
}

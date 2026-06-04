@file:JvmName("template_using_directive_typedef_runme")

import template_using_directive_typedef.*

fun main() {
    try {
        System.loadLibrary("template_using_directive_typedef")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val vo = Vector_Obj()

    val h = Holder()
    h.holder_use1(vo, vo, vo)
    h.holder_use2(vo, vo, vo)
    h.holder_use3(vo, vo, vo)

    template_using_directive_typedef.tns_holder_use(vo, vo)
    template_using_directive_typedef.tns_use(vo, vo, vo)
    template_using_directive_typedef.global_holder_use(vo)
    template_using_directive_typedef.global_use(vo, vo, vo)
    template_using_directive_typedef.ns1_holder_use(vo)
    template_using_directive_typedef.ns2_holder_use(vo, vo, vo, vo)
}

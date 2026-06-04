@file:JvmName("template_partial_specialization_runme")

import template_partial_specialization.*

fun main() {
    try {
        System.loadLibrary("template_partial_specialization")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // One parameter tests
    A().a()
    B().b()
    C().c()
    D().d()
    E().e()

    F().f()
    G().g()
    H().h()

    J().j()
    K().k()
    M().m()
    N().n()

    BB().b()
    BBB().b()
    BBBB().b()
    BBBBB().b()

    B1().b()
    B2().b()
    B3().b()
    B4().b()

    // Two parameter tests
    A_().a()
    B_().b()
    C_().c()
    D_().d()
    E_().e()
    F_().f()
    G_().g()

    C1_().c()
    C2_().c()
    C3_().c()
    C4_().c()
    B1_().b()
    E1_().e()
    E2_().e()
}

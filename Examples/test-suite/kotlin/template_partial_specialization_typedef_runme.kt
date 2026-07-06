@file:JvmName("template_partial_specialization_typedef_runme")

import template_partial_specialization_typedef.*

fun main() {
    try {
        System.loadLibrary("template_partial_specialization_typedef")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val dub = 11.1
    val concrete = Concrete()

    // One parameter tests
    A().a()
    B().b(); B().bb(dub)
    C().c(); C().cc(dub)
    D().d(); D().dd(dub)
    E().e(); E().ee(dub)

    F().f()
    G().g()
    H().h()

    J().j()
    K().k()
    M().m()
    N().n()

    BB().b(); BB().bb(true)
    BBB().b(); BBB().bb('A')
    BBBB().b(); BBBB().bb(12.toShort())
    BBBBB().b(); BBBBB().bb(123)

    B1().b()
    B2().b()
    B3().b()
    B4().b()

    // Two parameter tests
    A_().a()
    B_().b(); B_().bbb(dub)
    C_().c(); C_().ccc(dub)
    D_().d(); D_().ddd(123)
    E_().e()
    F_().f()
    G_().g()

    C1_().c(); C1_().ccc(concrete)
    C2_().c(); C2_().ccc(concrete)
    C3_().c(); C3_().ccc(concrete)
    C4_().c(); C4_().ccc(concrete)
    B1_().b(); B1_().bbb(concrete)
    E1_().e()
    E2_().e()
}

@file:JvmName("using_directive_and_declaration_runme")

import using_directive_and_declaration.*

fun main() {
    try {
        System.loadLibrary("using_directive_and_declaration")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    using_directive_and_declaration.useit1(Thing1())
    using_directive_and_declaration.useit2(Thing2())
    using_directive_and_declaration.useit3(Thing3())
    using_directive_and_declaration.useit4(Thing4())
    using_directive_and_declaration.useit5(Thing5())
    val t6a = Thing6a()
    t6a.a()
    val t6b = Thing6()
    t6b.b()
    using_directive_and_declaration.useit6(t6a, t6b)
    using_directive_and_declaration.useit7(Thing7())
}

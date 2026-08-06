@file:JvmName("using_directive_and_declaration_forward_runme")

import using_directive_and_declaration_forward.*

fun main() {
    try {
        System.loadLibrary("using_directive_and_declaration_forward")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    using_directive_and_declaration_forward.useit1(Thing1())
    using_directive_and_declaration_forward.useit1a(Thing1())
    using_directive_and_declaration_forward.useit1b(Thing1())
    using_directive_and_declaration_forward.useit1c(Thing1())

    using_directive_and_declaration_forward.useit2(Thing2())
    using_directive_and_declaration_forward.useit2a(Thing2())
    using_directive_and_declaration_forward.useit2b(Thing2())
    using_directive_and_declaration_forward.useit2c(Thing2())
    using_directive_and_declaration_forward.useit2d(Thing2())

    using_directive_and_declaration_forward.useit3(Thing3())
    using_directive_and_declaration_forward.useit3a(Thing3())
    using_directive_and_declaration_forward.useit3b(Thing3())
    using_directive_and_declaration_forward.useit3c(Thing3())
    using_directive_and_declaration_forward.useit3d(Thing3())

    using_directive_and_declaration_forward.useit4(Thing4())
    using_directive_and_declaration_forward.useit4a(Thing4())
    using_directive_and_declaration_forward.useit4b(Thing4())
    using_directive_and_declaration_forward.useit4c(Thing4())
    using_directive_and_declaration_forward.useit4d(Thing4())

    using_directive_and_declaration_forward.useit5(Thing5())
    using_directive_and_declaration_forward.useit5a(Thing5())
    using_directive_and_declaration_forward.useit5b(Thing5())
    using_directive_and_declaration_forward.useit5c(Thing5())
    using_directive_and_declaration_forward.useit5d(Thing5())

    using_directive_and_declaration_forward.useit7(Thing7())
    using_directive_and_declaration_forward.useit7a(Thing7())
    using_directive_and_declaration_forward.useit7b(Thing7())
    using_directive_and_declaration_forward.useit7c(Thing7())
    using_directive_and_declaration_forward.useit7d(Thing7())
}

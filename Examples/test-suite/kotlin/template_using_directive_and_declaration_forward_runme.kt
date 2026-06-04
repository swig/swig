@file:JvmName("template_using_directive_and_declaration_forward_runme")

import template_using_directive_and_declaration_forward.*

fun main() {
    try {
        System.loadLibrary("template_using_directive_and_declaration_forward")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    template_using_directive_and_declaration_forward.useit1(Thing1Int())
    template_using_directive_and_declaration_forward.useit1a(Thing1Int())
    template_using_directive_and_declaration_forward.useit1b(Thing1Int())
    template_using_directive_and_declaration_forward.useit1c(Thing1Int())

    template_using_directive_and_declaration_forward.useit2(Thing2Int())
    template_using_directive_and_declaration_forward.useit2a(Thing2Int())
    template_using_directive_and_declaration_forward.useit2b(Thing2Int())
    template_using_directive_and_declaration_forward.useit2c(Thing2Int())
    template_using_directive_and_declaration_forward.useit2d(Thing2Int())

    template_using_directive_and_declaration_forward.useit3(Thing3Int())
    template_using_directive_and_declaration_forward.useit3a(Thing3Int())
    template_using_directive_and_declaration_forward.useit3b(Thing3Int())
    template_using_directive_and_declaration_forward.useit3c(Thing3Int())
    template_using_directive_and_declaration_forward.useit3d(Thing3Int())

    template_using_directive_and_declaration_forward.useit4(Thing4Int())
    template_using_directive_and_declaration_forward.useit4a(Thing4Int())
    template_using_directive_and_declaration_forward.useit4b(Thing4Int())
    template_using_directive_and_declaration_forward.useit4c(Thing4Int())
    template_using_directive_and_declaration_forward.useit4d(Thing4Int())

    template_using_directive_and_declaration_forward.useit5(Thing5Int())
    template_using_directive_and_declaration_forward.useit5a(Thing5Int())
    template_using_directive_and_declaration_forward.useit5b(Thing5Int())
    template_using_directive_and_declaration_forward.useit5c(Thing5Int())
    template_using_directive_and_declaration_forward.useit5d(Thing5Int())

    template_using_directive_and_declaration_forward.useit7(Thing7Int())
    template_using_directive_and_declaration_forward.useit7a(Thing7Int())
    template_using_directive_and_declaration_forward.useit7b(Thing7Int())
    template_using_directive_and_declaration_forward.useit7c(Thing7Int())
    template_using_directive_and_declaration_forward.useit7d(Thing7Int())
}

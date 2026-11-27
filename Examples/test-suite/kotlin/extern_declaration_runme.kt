@file:JvmName("extern_declaration_runme")

import extern_declaration.*

fun main() {
    try {
        System.loadLibrary("extern_declaration")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    if (extern_declaration.externimport(100) != 100) throw RuntimeException("externimport failed")
    if (extern_declaration.externexport(200) != 200) throw RuntimeException("externexport failed")
    if (extern_declaration.externstdcall(300) != 300) throw RuntimeException("externstdcall failed")
}

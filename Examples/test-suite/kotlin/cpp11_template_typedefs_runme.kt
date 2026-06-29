@file:JvmName("cpp11_template_typedefs_runme")

import cpp11_template_typedefs.*

fun main() {
    try {
        System.loadLibrary("cpp11_template_typedefs")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val alloc1 = cpp11_template_typedefs.get_bucket_allocator1()
    val alloc2 = cpp11_template_typedefs.get_bucket_allocator2()
}

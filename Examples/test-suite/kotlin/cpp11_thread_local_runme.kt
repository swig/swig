@file:JvmName("cpp11_thread_local_runme")

import cpp11_thread_local.*

fun main() {
    try {
        System.loadLibrary("cpp11_thread_local")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    if (ThreadLocals.stval != 11)
        throw RuntimeException()
    if (ThreadLocals.tsval != 22)
        throw RuntimeException()
    if (ThreadLocals.tscval99 != 99)
        throw RuntimeException()

    cpp11_thread_local.etval = -11
    if (cpp11_thread_local.etval != -11)
        throw RuntimeException()

    cpp11_thread_local.stval = -22
    if (cpp11_thread_local.stval != -22)
        throw RuntimeException()

    cpp11_thread_local.tsval = -33
    if (cpp11_thread_local.tsval != -33)
        throw RuntimeException()

    cpp11_thread_local.etval = -44
    if (cpp11_thread_local.etval != -44)
        throw RuntimeException()

    cpp11_thread_local.teval = -55
    if (cpp11_thread_local.teval != -55)
        throw RuntimeException()

    cpp11_thread_local.ectval = -55
    if (cpp11_thread_local.ectval != -55)
        throw RuntimeException()

    cpp11_thread_local.ecpptval = -66
    if (cpp11_thread_local.ecpptval != -66)
        throw RuntimeException()
}

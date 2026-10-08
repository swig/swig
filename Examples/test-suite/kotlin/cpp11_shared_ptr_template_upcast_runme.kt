@file:JvmName("cpp11_shared_ptr_template_upcast_runme")

import cpp11_shared_ptr_template_upcast.*

fun main() {
    try {
        System.loadLibrary("cpp11_shared_ptr_template_upcast")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val pd = cpp11_shared_ptr_template_upcast.MakePrintableDerived(20)
    pd!!.GetResult()
    pd.GetFormatted()
}

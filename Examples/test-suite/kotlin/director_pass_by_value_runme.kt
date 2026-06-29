@file:JvmName("director_pass_by_value_runme")

import director_pass_by_value.*

var passByVal: PassedByValue? = null

class director_pass_by_value_Derived : DirectorPassByValueAbstractBase() {
    override fun virtualMethod(pbv: PassedByValue) {
        passByVal = pbv
    }
}

private fun WaitForGC() {
    System.gc()
    System.runFinalization()
    try {
        java.lang.Thread.sleep(10)
    } catch (e: InterruptedException) {
    }
}

fun main() {
    try {
        System.loadLibrary("director_pass_by_value")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val caller = Caller()
    caller.call_virtualMethod(director_pass_by_value_Derived())
    run {
        var countdown = 5
        while (true) {
            WaitForGC()
            if (--countdown == 0)
                break
        }
    }
    if (director_pass_by_value.has_cplusplus11())
        Counter.check_counts(1, 0, 0, 1, 0, 1) // check move constructor called and just one destructor
    // bug was the passByVal 'global' object was destroyed after the call to virtualMethod had finished.
    val ret = passByVal!!.getVal()
    if (ret != 0x12345678)
        throw RuntimeException("Bad return value, got " + Integer.toHexString(ret))
}

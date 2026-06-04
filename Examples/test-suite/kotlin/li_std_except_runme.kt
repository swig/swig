@file:JvmName("li_std_except_runme")

import li_std_except.*

fun main() {
    try {
        System.loadLibrary("li_std_except")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val test = Test()
    try { test.throw_bad_exception(); throw RuntimeException("throw_bad_exception failed") } catch (e: RuntimeException) {}
    try { test.throw_domain_error(); throw RuntimeException("throw_domain_error failed") } catch (e: RuntimeException) { if (e.message != "oops") throw RuntimeException("wrong message returned") }
    try { test.throw_exception(); throw RuntimeException("throw_exception failed") } catch (e: RuntimeException) {}
    try { test.throw_invalid_argument(); throw RuntimeException("throw_invalid_argument failed") } catch (e: IllegalArgumentException) { if (e.message != "oops") throw RuntimeException("wrong message returned") }
    try { test.throw_length_error(); throw RuntimeException("throw_length_error failed") } catch (e: IndexOutOfBoundsException) { if (e.message != "oops") throw RuntimeException("wrong message returned") }
    try { test.throw_logic_error(); throw RuntimeException("throw_logic_error failed") } catch (e: RuntimeException) { if (e.message != "oops") throw RuntimeException("wrong message returned") }
    try { test.throw_out_of_range(); throw RuntimeException("throw_out_of_range failed") } catch (e: IndexOutOfBoundsException) { if (e.message != "oops") throw RuntimeException("wrong message returned") }
    try { test.throw_overflow_error(); throw RuntimeException("throw_overflow_error failed") } catch (e: ArithmeticException) { if (e.message != "oops") throw RuntimeException("wrong message returned") }
    try { test.throw_range_error(); throw RuntimeException("throw_range_error failed") } catch (e: IndexOutOfBoundsException) { if (e.message != "oops") throw RuntimeException("wrong message returned") }
    try { test.throw_runtime_error(); throw RuntimeException("throw_runtime_error failed") } catch (e: RuntimeException) { if (e.message != "oops") throw RuntimeException("wrong message returned") }
    try { test.throw_underflow_error(); throw RuntimeException("throw_underflow_error failed") } catch (e: ArithmeticException) { if (e.message != "oops") throw RuntimeException("wrong message returned") }
}

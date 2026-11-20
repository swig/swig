@file:JvmName("li_constraints_runme")

import li_constraints.*

fun checkDouble(except: Boolean, f: (Double) -> Unit, value: Double, ex: String) {
    var actual = true
    var proper = false
    try {
        f(value)
    } catch (e: RuntimeException) {
        actual = false
        proper = e.message == "Expected a " + ex + " value."
    }
    if (actual) {
        if (!except) {
            throw RuntimeException("function '" + ex + "' with " + value + " should perform an exception")
        }
    } else {
        if (except) {
            throw RuntimeException("function '" + ex + "' with " + value + " should not perform an exception")
        } else if (!proper) {
            throw RuntimeException("function '" + ex + "' with " + value + " should perform a proper exception")
        }
    }
}

fun main() {
    try {
        System.loadLibrary("li_constraints")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    var func: (Double) -> Unit = { v -> li_constraints.test_nonnegative(v) }
    checkDouble(true, func, 10.0, "non-negative")
    checkDouble(true, func, 0.0, "non-negative")
    checkDouble(false, func, -10.0, "non-negative")

    func = { v -> li_constraints.test_nonpositive(v) }
    checkDouble(false, func, 10.0, "non-positive")
    checkDouble(true, func, 0.0, "non-positive")
    checkDouble(true, func, -10.0, "non-positive")

    func = { v -> li_constraints.test_positive(v) }
    checkDouble(true, func, 10.0, "positive")
    checkDouble(false, func, 0.0, "positive")
    checkDouble(false, func, -10.0, "positive")

    func = { v -> li_constraints.test_negative(v) }
    checkDouble(false, func, 10.0, "negative")
    checkDouble(false, func, 0.0, "negative")
    checkDouble(true, func, -10.0, "negative")

    func = { v -> li_constraints.test_nonzero(v) }
    checkDouble(true, func, 10.0, "nonzero")
    checkDouble(false, func, 0.0, "nonzero")
    checkDouble(true, func, -10.0, "nonzero")

    var haveException = false
    try {
        li_constraints.test_nonnull(null)
    } catch (e: Exception) {
        haveException = e.message == "Received a NULL pointer."
    }
    if (!haveException) {
        throw RuntimeException("test_nonnull should perform proper exception with 'null' value")
    }
    val nonnull = li_constraints.get_nonnull()
    li_constraints.test_nonnull(nonnull)
}

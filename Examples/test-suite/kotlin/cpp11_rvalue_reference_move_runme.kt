@file:JvmName("cpp11_rvalue_reference_move_runme")

import cpp11_rvalue_reference_move.*

fun main() {
    try {
        System.loadLibrary("cpp11_rvalue_reference_move")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    run {
        // Function containing rvalue reference parameter
        Counter.reset_counts()
        val mo = MovableCopyable(222)
        Counter.check_counts(1, 0, 0, 0, 0, 0)
        MovableCopyable.movein(mo)
        Counter.check_counts(1, 0, 0, 1, 0, 2)
        if (!MovableCopyable.is_nullptr(mo))
            throw RuntimeException("is_nullptr failed")
        mo.delete()
        Counter.check_counts(1, 0, 0, 1, 0, 2)
    }

    run {
        // Move constructor test
        Counter.reset_counts()
        val mo = MovableCopyable(222)
        Counter.check_counts(1, 0, 0, 0, 0, 0)
        val mo_moved = MovableCopyable(mo)
        Counter.check_counts(1, 0, 0, 1, 0, 1)
        if (!MovableCopyable.is_nullptr(mo))
            throw RuntimeException("is_nullptr failed")
        mo.delete()
        Counter.check_counts(1, 0, 0, 1, 0, 1)
        mo_moved.delete()
        Counter.check_counts(1, 0, 0, 1, 0, 2)
    }

    run {
        // Move assignment operator test
        Counter.reset_counts()
        val mo111 = MovableCopyable(111)
        val mo222 = MovableCopyable(222)
        Counter.check_counts(2, 0, 0, 0, 0, 0)
        mo111.MoveAssign(mo222)
        Counter.check_counts(2, 0, 0, 0, 1, 1)
        if (!MovableCopyable.is_nullptr(mo222))
            throw RuntimeException("is_nullptr failed")
        mo222.delete()
        Counter.check_counts(2, 0, 0, 0, 1, 1)
        mo111.delete()
        Counter.check_counts(2, 0, 0, 0, 1, 2)
    }

    // null check omitted: the Kotlin movein() parameter is a non-null type,
    // so the C++ null guard is unreachable and cannot be exercised here.

    run {
        // output
        Counter.reset_counts()
        val mc = MovableCopyable.moveout(1234)
        Counter.check_counts(2, 0, 0, 0, 1, 1)
        MovableCopyable.check_numbers_match(mc, 1234)

        var exception_thrown = false
        try {
            MovableCopyable.movein(mc)
        } catch (e: RuntimeException) {
            if (e.message?.contains("Cannot release ownership as memory is not owned") != true)
                throw RuntimeException("incorrect exception message")
            exception_thrown = true
        }
        if (!exception_thrown)
            throw RuntimeException("Should have thrown 'Cannot release ownership as memory is not owned' error")
        Counter.check_counts(2, 0, 0, 0, 1, 1)
    }
}

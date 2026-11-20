@file:JvmName("catches_strings_runme")

import catches_strings.*

fun main() {
    try {
        System.loadLibrary("catches_strings")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    run {
        var exceptionThrown = false
        try {
            StringsThrower.charstring()
        } catch (e: RuntimeException) {
            if (e.message?.contains("charstring message") != true)
                throw RuntimeException("incorrect exception message")
            exceptionThrown = true
        }
        if (!exceptionThrown)
            throw RuntimeException("Should have thrown an exception")
    }

    run {
        var exceptionThrown = false
        try {
            StringsThrower.stdstring()
        } catch (e: RuntimeException) {
            if (e.message?.contains("stdstring message") != true)
                throw RuntimeException("incorrect exception message")
            exceptionThrown = true
        }
        if (!exceptionThrown)
            throw RuntimeException("Should have thrown an exception")
    }
}

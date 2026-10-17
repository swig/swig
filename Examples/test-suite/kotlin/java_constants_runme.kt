@file:JvmName("java_constants_runme")

import java_constants.*

// This testcase uses the %javaconst directive to control how constants are initialised.
// In Kotlin the constants are emitted directly onto the module object (there is no
// separate constants interface as in Java), so we verify the generated values instead.
// The %javaconst(1) constants are compile-time initialised (e.g. CHINA, BRISTOLS,
// APPLES) while the %javaconst(0) ones are initialised from a JNI call (TOM,
// ORCHESTRA_STALLS, PORKY, ROSY). A Kotlin `when` works with either form, so it is used
// here in place of the Java switch statement.

fun main() {
    try {
        System.loadLibrary("java_constants")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val number = 200

    // when expression using compile-time constant values (analogous to the Java switch)
    when (number) {
        java_constants.CHINA -> {}
        java_constants.BRISTOLS -> {}
        else -> {}
    }

    if (java_constants.DIPSTICK.toInt() != 100)
        throw RuntimeException("Incorrect value for DIPSTICK")
    if (java_constants.CHINA != 200)
        throw RuntimeException("Incorrect value for CHINA")
    if (java_constants.TOM != java.math.BigInteger("300"))
        throw RuntimeException("Incorrect value for TOM")
    if (java_constants.ORCHESTRA_STALLS != 400L)
        throw RuntimeException("Incorrect value for ORCHESTRA_STALLS")
    if (java_constants.JAM_JAR != "500")
        throw RuntimeException("Incorrect value for JAM_JAR")
    if (java_constants.OXO != '6')
        throw RuntimeException("Incorrect value for OXO")
    if (java_constants.PORKY != false)
        throw RuntimeException("Incorrect value for PORKY")
    if (java_constants.BRISTOLS != 800)
        throw RuntimeException("Incorrect value for BRISTOLS")
    if (java_constants.APPLES != 100L)
        throw RuntimeException("Incorrect value for APPLES")
    if (java_constants.ROSY != 900L)
        throw RuntimeException("Incorrect value for ROSY")

    // Bitwise and shift constants - check the C operators were translated correctly
    if (java_constants.BIT_SHIFT != 1)
        throw RuntimeException("Incorrect value for BIT_SHIFT")
    if (java_constants.BIT_OR != 255)
        throw RuntimeException("Incorrect value for BIT_OR")
    if (java_constants.BIT_COMBO != 12)
        throw RuntimeException("Incorrect value for BIT_COMBO")
    if (java_constants.BIT_AND != 15)
        throw RuntimeException("Incorrect value for BIT_AND")
    if (java_constants.BIT_XOR != 240)
        throw RuntimeException("Incorrect value for BIT_XOR")
    if (java_constants.BIT_INV != -1)
        throw RuntimeException("Incorrect value for BIT_INV")
    if (java_constants.BIT_PREC != 8)
        throw RuntimeException("Incorrect value for BIT_PREC")
    if (java_constants.BIT_LONG != 1099511627776L)
        throw RuntimeException("Incorrect value for BIT_LONG")
}

@file:JvmName("kotlin_constants_runme")

import kotlin_constants.*

// This testcase uses the %kotlinconst directive to control how constants are initialised.
// In Kotlin the constants are emitted directly onto the module object (there is no
// separate constants interface as in Java), so we verify the generated values instead.
// The %kotlinconst(1) constants are compile-time initialised (e.g. CHINA, BRISTOLS,
// APPLES) while the %kotlinconst(0) ones are initialised from a JNI call (TOM,
// ORCHESTRA_STALLS, PORKY, ROSY). A Kotlin `when` works with either form, so it is used
// here in place of the Java switch statement.

fun main() {
    try {
        System.loadLibrary("kotlin_constants")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val number = 200

    // when expression using compile-time constant values (analogous to the Java switch)
    when (number) {
        kotlin_constants.CHINA -> {}
        kotlin_constants.BRISTOLS -> {}
        else -> {}
    }

    if (kotlin_constants.DIPSTICK.toInt() != 100)
        throw RuntimeException("Incorrect value for DIPSTICK")
    if (kotlin_constants.CHINA != 200)
        throw RuntimeException("Incorrect value for CHINA")
    if (kotlin_constants.TOM != java.math.BigInteger("300"))
        throw RuntimeException("Incorrect value for TOM")
    if (kotlin_constants.ORCHESTRA_STALLS != 400L)
        throw RuntimeException("Incorrect value for ORCHESTRA_STALLS")
    if (kotlin_constants.JAM_JAR != "500")
        throw RuntimeException("Incorrect value for JAM_JAR")
    if (kotlin_constants.OXO != '6')
        throw RuntimeException("Incorrect value for OXO")
    if (kotlin_constants.PORKY != false)
        throw RuntimeException("Incorrect value for PORKY")
    if (kotlin_constants.BRISTOLS != 800)
        throw RuntimeException("Incorrect value for BRISTOLS")
    if (kotlin_constants.APPLES != 100L)
        throw RuntimeException("Incorrect value for APPLES")
    if (kotlin_constants.ROSY != 900L)
        throw RuntimeException("Incorrect value for ROSY")

    // Bitwise and shift constants - check the C operators were translated correctly
    if (kotlin_constants.BIT_SHIFT != 1)
        throw RuntimeException("Incorrect value for BIT_SHIFT")
    if (kotlin_constants.BIT_OR != 255)
        throw RuntimeException("Incorrect value for BIT_OR")
    if (kotlin_constants.BIT_COMBO != 12)
        throw RuntimeException("Incorrect value for BIT_COMBO")
    if (kotlin_constants.BIT_AND != 15)
        throw RuntimeException("Incorrect value for BIT_AND")
    if (kotlin_constants.BIT_XOR != 240)
        throw RuntimeException("Incorrect value for BIT_XOR")
    if (kotlin_constants.BIT_INV != -1)
        throw RuntimeException("Incorrect value for BIT_INV")
    if (kotlin_constants.BIT_PREC != 8)
        throw RuntimeException("Incorrect value for BIT_PREC")
    if (kotlin_constants.BIT_LONG != 1099511627776L)
        throw RuntimeException("Incorrect value for BIT_LONG")
}

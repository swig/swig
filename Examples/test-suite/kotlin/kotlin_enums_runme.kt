@file:JvmName("kotlin_enums_runme")

import kotlin_enums.*

// This testcase uses the %kotlinconst directive to control how enums are initialised.
// With enumtypeunsafe.swg the enum items are generated as Int constants on a companion
// object (e.g. stuff.FIDDLE). Kotlin has no "implements interface to drop the qualifier"
// mechanism like Java, so the enum items are always referenced through their holder
// class. A Kotlin `when` is used in place of the Java switch statement.

fun main() {
    try {
        System.loadLibrary("kotlin_enums")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    if (WithTrailingComma.Second != 1)
        throw RuntimeException("Incorrect value for Second")

    if (WithTrailingCommaAndIgnoredFirstItem.SecondNonIgnoredOne != 2)
        throw RuntimeException("Incorrect value for SecondNonIgnoredOne")

    val number = 200

    // when expression - only compiles if these enum values are accessible (analogous to
    // the Java switch statement).
    when (number) {
        stuff.FIDDLE -> {}
        stuff.STICKS -> {}
        stuff.BONGO -> {}
        stuff.DRUMS -> {}
        else -> {}
    }
    if (stuff.DRUMS != 15)
        throw RuntimeException("Incorrect value for DRUMS")

    // check typemaps use short for this enum
    val poppycock: Short = nonsense.POPPYCOCK
    val tst1: Short = kotlin_enums.test1(poppycock)
    val tst2: Short = kotlin_enums.test2(poppycock)
    if (tst1 != poppycock || tst2 != poppycock)
        throw RuntimeException("Incorrect short enum round-trip")

    // Test the %kotlinconstvalue directive for enums
    if (Numero.Quattro != 4)
        throw RuntimeException("Incorrect value for Quattro")

    // Test boolean enums
    if (play_state.PLAY != 1 || play_state.STOP != 0)
        throw RuntimeException("Incorrect value for boolean enum")
}

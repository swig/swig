@file:JvmName("overload_complicated_runme")

import overload_complicated.*

fun main() {
    try {
        System.loadLibrary("overload_complicated")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val pInt: SWIGTYPE_p_int? = null

    // Check the correct constructors are available
    var p = Pop(pInt)

    p = Pop(pInt, false)

    // Check overloaded in const only and pointers/references which target languages cannot disambiguate
    if (p.hip(false) != 701)
        throw RuntimeException("Test 1 failed")

    if (p.hip(pInt) != 702)
        throw RuntimeException("Test 2 failed")

    // Reverse the order for the above
    if (p.hop(pInt) != 805)
        throw RuntimeException("Test 3 failed")

    if (p.hop(false) != 801)
        throw RuntimeException("Test 4 failed")

    // Few more variations and order shuffled
    if (p.pop(false) != 901)
        throw RuntimeException("Test 5 failed")

    if (p.pop(pInt) != 902)
        throw RuntimeException("Test 6 failed")

    if (p.pop() != 905)
        throw RuntimeException("Test 7 failed")

    // Overload on const only
    if (p.bop(pInt) != 1001)
        throw RuntimeException("Test 8 failed")

    if (p.bip(pInt) != 2001)
        throw RuntimeException("Test 9 failed")

    // Globals
    if (overload_complicated.muzak(false) != 3001)
        throw RuntimeException("Test 10 failed")

    if (overload_complicated.muzak(pInt) != 3002)
        throw RuntimeException("Test 11 failed")
}

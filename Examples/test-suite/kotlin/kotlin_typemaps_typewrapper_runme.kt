@file:JvmName("kotlin_typemaps_typewrapper_runme")

import kotlin_typemaps_typewrapper.*

fun main() {
    try {
        System.loadLibrary("kotlin_typemaps_typewrapper")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val greet = SWIGTYPE_p_Greeting.CreateNullPointer()
    val bye = SWIGTYPE_p_Farewell.CreateNullPointer()

    // Check that pure Kotlin methods have been added
    greet.sayhello()
    bye.saybye(java.math.BigDecimal(java.math.BigInteger.ONE))

    // Check that SWIGTYPE_p_Greeting is derived from Exception
    try {
        throw SWIGTYPE_p_Greeting.CreateNullPointer()
    } catch (g: SWIGTYPE_p_Greeting) {
        val msg = g.message
    }

    // Check that SWIGTYPE_p_Greeting has implemented the EventListener interface
    SWIGTYPE_p_Greeting.cheerio(greet)

    // The default getCPtr() call in each method would throw if null is passed.
    // Make sure the modified version works with and without null objects.
    kotlin_typemaps_typewrapper.solong(null)
    kotlin_typemaps_typewrapper.solong(bye)

    // Create a NULL pointer for Farewell using the constructor with changed modifiers
    val nullFarewell = SWIGTYPE_p_Farewell(0, false)
}

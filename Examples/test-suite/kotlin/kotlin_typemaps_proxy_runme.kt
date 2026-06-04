@file:JvmName("kotlin_typemaps_proxy_runme")

import kotlin_typemaps_proxy.*
import java.lang.reflect.Modifier

fun main() {
    try {
        System.loadLibrary("kotlin_typemaps_proxy")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val greet = Greeting()
    val bye = Farewell()

    // Check that pure Kotlin methods have been added
    greet.sayhello()
    bye.saybye(java.math.BigDecimal(java.math.BigInteger.ONE))

    // No finalize method so may as well delete manually
    bye.delete()

    // Check that Greeting is derived from Exception
    try {
        throw Greeting()
    } catch (g: Greeting) {
        val msg = g.message
    }

    // Check that Greeting has implemented the EventListener interface
    Greeting.cheerio(greet)

    // The default getCPtr() call in each method would throw if null is passed.
    // Make sure the modified version works with and without null objects.
    Greeting.ciao(null)
    Greeting.ciao(greet)

    // Create a NULL pointer for Farewell using the constructor with changed modifiers
    val nullFarewell = Farewell(0, false)

    // Test typemaps are being found for templated classes
    AdieuIntPtrPtr.adieu()

    // Check the %kotlinmethodmodifiers feature
    try {
        val methodmodifiertest = nullFarewell.javaClass.getDeclaredMethod("methodmodifiertest")
        if (!Modifier.isPrivate(methodmodifiertest.modifiers))
            throw RuntimeException("NS::Farewell::methodmodifiertest not private")
    } catch (n: NoSuchMethodException) {
        throw RuntimeException("NoSuchMethodException caught. Test failed.")
    } catch (s: SecurityException) {
        throw RuntimeException("SecurityException caught. Test failed.")
    }

    // Check the premature garbage collection prevention parameter
    // Check it is normally present
    val nullPtr = 0L
    val with = With(null)
    kotlin_typemaps_proxyJNI.new_With(nullPtr, with)
    kotlin_typemaps_proxyJNI.With_static_method(nullPtr, with)
    kotlin_typemaps_proxyJNI.With_member_method(nullPtr, with, nullPtr, with)
    kotlin_typemaps_proxyJNI.delete_With(nullPtr)
    kotlin_typemaps_proxyJNI.global_method_with(nullPtr, with)

    // Check that it can be turned off
    kotlin_typemaps_proxyJNI.new_Without(nullPtr)
    kotlin_typemaps_proxyJNI.Without_static_method(nullPtr)
    kotlin_typemaps_proxyJNI.Without_member_method(nullPtr, nullPtr)
    kotlin_typemaps_proxyJNI.delete_Without(nullPtr)
    kotlin_typemaps_proxyJNI.global_method_without(nullPtr)

    // $imfuncname substitution
    val pa = ProxyA()
    if (pa.imfuncname_test() != 123)
        throw RuntimeException("imfuncname_test is not 123")
    if (ProxyA.imfuncname_static_test() != 234)
        throw RuntimeException("imfuncname_test is not 234")
    if (kotlin_typemaps_proxy.imfuncname_global_test() != 345)
        throw RuntimeException("imfuncname_test is not 345")
}

@file:JvmName("kotlin_director_exception_feature_nspace_runme")

import kotlin_director_exception_feature_nspacePackage.*
import kotlin_director_exception_feature_nspacePackage.MyNS.*

object kotlin_director_exception_feature_nspace_Consts {
    const val PINGEXCP1 = "Ping MyKotlinException1"  // should get translated through an int on ping
    const val PINGEXCP2 = "Ping MyKotlinException2"

    const val PONGEXCP1 = "Pong MyKotlinException1"
    const val PONGEXCP2 = "Pong MyKotlinException2"
    const val PONGUNEXPECTED = "Pong MyKotlinUnexpected"
    const val TRANSLATED_NPE = "Pong Translated NPE"

    const val GENERICPONGEXCP1 = "GenericPong Wrapped MyKotlinException1"
    const val GENERICPONGEXCP2 = "GenericPong New Checked Exception"
    const val GENERICPONGEXCP3 = "GenericPong New Unchecked Exception"
    const val GENERICPONGEXCP4 = "GenericPong New Exception Without String ctor"
}

// an exception not mentioned or wrapped by the swig interface,
// to reconstruct using generic DirectorException handling
class kotlin_director_exception_feature_nspace_NewCheckedException(s: String) : Exception(s)

// an exception not mentioned or wrapped by the swig interface,
// to reconstruct using generic DirectorException handling
class kotlin_director_exception_feature_nspace_NewUncheckedException(s: String) : RuntimeException(s)

// an exception not constructible from a string,
// to test DirectorException fallback reconstruction
class kotlin_director_exception_feature_nspace_UnconstructibleException(a: Int, s: String) : Exception(s) {
    @Suppress("unused")
    private val extrastate: Int = a
}

class kotlin_director_exception_feature_nspace_MyFooDirectorImpl : Foo() {
    override fun ping(excp: Int): String {
        if (excp == 1) throw MyKotlinException1(kotlin_director_exception_feature_nspace_Consts.PINGEXCP1)
        if (excp == 2) throw MyKotlinException2(kotlin_director_exception_feature_nspace_Consts.PINGEXCP2)
        return "Ping director returned"
    }

    override fun pong(excp: Int): String {
        if (excp == 1) throw MyKotlinException1(kotlin_director_exception_feature_nspace_Consts.PONGEXCP1)
        if (excp == 2) throw MyKotlinException2(kotlin_director_exception_feature_nspace_Consts.PONGEXCP2)
        if (excp == 3) throw MyKotlinUnexpected(kotlin_director_exception_feature_nspace_Consts.PONGUNEXPECTED)
        if (excp == 4) throw NullPointerException(kotlin_director_exception_feature_nspace_Consts.TRANSLATED_NPE)  // should be translated to ::Unexpected
        return "Pong director returned"
    }

    override fun genericpong(excp: Int): String {
        if (excp == 1)
            throw MyKotlinException1(kotlin_director_exception_feature_nspace_Consts.GENERICPONGEXCP1)
        if (excp == 2)
            throw kotlin_director_exception_feature_nspace_NewCheckedException(kotlin_director_exception_feature_nspace_Consts.GENERICPONGEXCP2)
        if (excp == 3)
            throw kotlin_director_exception_feature_nspace_NewUncheckedException(kotlin_director_exception_feature_nspace_Consts.GENERICPONGEXCP3)
        if (excp == 4)
            throw kotlin_director_exception_feature_nspace_UnconstructibleException(1, kotlin_director_exception_feature_nspace_Consts.GENERICPONGEXCP4)
        return "GenericPong director returned"
    }
}

fun fail(msg: String) {
    System.err.println(msg)
    kotlin.system.exitProcess(1)
}

fun failif(cond: Boolean, msg: String) {
    if (cond) fail(msg)
}

fun main() {
    try {
        System.loadLibrary("kotlin_director_exception_feature_nspace")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val C = kotlin_director_exception_feature_nspace_Consts
    val b = Bar(kotlin_director_exception_feature_nspace_MyFooDirectorImpl())
    try {

        try { b.ping(0) } catch (e: Exception) {
            fail("Exception should not have been thrown: $e from ping(0)")
        }
        try { b.ping(1); fail("No exception thrown in ping(1)") } catch (e: MyKotlinException1) {
            // Should say "Threw some integer", see kotlin_director_exception_feature_nspace.i  Foo::ping throws a "1"
            failif("Threw some integer" != e.message, "Ping exception not translated through int: '${e.message}'")
        }
        try { b.ping(2); fail("No exception thrown in ping(2)") } catch (e: MyKotlinException2) {
            failif(C.PINGEXCP2 != e.message, "Expected exception has unexpected message: '${e.message}'")
        }

        try { b.pong(0) } catch (e: Exception) {
            fail("Exception should not have been thrown: $e from pong(0)")
        }
        try { b.pong(1); fail("No exception thrown in pong(1)") } catch (e: MyKotlinException1) {
            failif(C.PONGEXCP1 != e.message, "Expected exception has unexpected message: '${e.message}'")
        }
        try { b.pong(2); fail("No exception thrown in pong(2)") } catch (e: MyKotlinException2) {
            failif(C.PONGEXCP2 != e.message, "Expected exception has unexpected message: '${e.message}'")
        }
        try { b.pong(3); fail("No exception thrown in pong(3)") } catch (e: MyKotlinUnexpected) {
            failif(C.PONGUNEXPECTED != e.message, "Expected exception has unexpected message: '${e.message}'")
        }
        try { b.pong(4); fail("No exception thrown in pong(4)") } catch (e: MyKotlinUnexpected) {
            failif(C.TRANSLATED_NPE != e.message, "Expected exception has unexpected message: '${e.message}'")
        }


        try { b.genericpong(0) } catch (e: Exception) {
            fail("Exception should not have been thrown: $e from genericpong(0)")
        }
        try { b.genericpong(1); fail("No exception thrown in genericpong(1)") } catch (e: MyKotlinException1) {
            failif(C.GENERICPONGEXCP1 != e.message, "Expected exception has unexpected message: '${e.message}'")
        }
        try { b.genericpong(2); fail("No exception thrown in genericpong(2)") } catch (e: kotlin_director_exception_feature_nspace_NewCheckedException) {
            failif(C.GENERICPONGEXCP2 != e.message, "Expected exception has unexpected message: '${e.message}'")
        }
        try { b.genericpong(3); fail("No exception thrown in genericpong(3)") } catch (e: kotlin_director_exception_feature_nspace_NewUncheckedException) {
            failif(C.GENERICPONGEXCP3 != e.message, "Expected exception has unexpected message: '${e.message}'")
        }
        try { b.genericpong(4); fail("No exception thrown in genericpong(4)") } catch (e: RuntimeException) {
            failif(e.javaClass != RuntimeException::class.java, "Exception $e is not exactly RuntimeException")
            failif("Unspecified DirectorException message" != e.message, "Expected exception has unexpected message: '${e.message}'")
        }
    } catch (e: Exception) {
        e.printStackTrace()
        fail("Unexpected exception thrown or exception not mapped properly")
    }
}

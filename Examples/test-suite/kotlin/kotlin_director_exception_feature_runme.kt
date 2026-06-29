@file:JvmName("kotlin_director_exception_feature_runme")

import kotlin_director_exception_feature.*

// Kotlin has no checked exceptions, so the director implementations below do not declare
// 'throws' clauses (the C++ 'throws' typemaps still control which kotlin exception class is
// rethrown to the caller). This test exercises the same director:except / directorthrows /
// throws machinery as the Java test, verifying runtime exception propagation through the
// director boundary in both directions (Kotlin -> C++ -> Kotlin).

object Consts {
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
class NewCheckedException(s: String) : Exception(s)

// an exception not mentioned or wrapped by the swig interface,
// to reconstruct using generic DirectorException handling
class NewUncheckedException(s: String) : RuntimeException(s)

// an exception not constructable from a string,
// to test DirectorException fallback reconstruction
class UnconstructableException(a: Int, s: String) : Exception(s) {
    private val extrastate: Int = a
}

class MyFooDirectorImpl : Foo() {
    override fun ping(excp: Int): String {
        if (excp == 1) throw MyKotlinException1(Consts.PINGEXCP1)
        if (excp == 2) throw MyKotlinException2(Consts.PINGEXCP2)
        return "Ping director returned"
    }

    override fun pong(excp: Int): String {
        if (excp == 1) throw MyKotlinException1(Consts.PONGEXCP1)
        if (excp == 2) throw MyKotlinException2(Consts.PONGEXCP2)
        if (excp == 3) throw MyKotlinUnexpected(Consts.PONGUNEXPECTED)
        if (excp == 4) throw NullPointerException(Consts.TRANSLATED_NPE)  // should be translated to ::Unexpected
        return "Pong director returned"
    }

    override fun genericpong(excp: Int): String {
        if (excp == 1) throw MyKotlinException1(Consts.GENERICPONGEXCP1)
        if (excp == 2) throw NewCheckedException(Consts.GENERICPONGEXCP2)
        if (excp == 3) throw NewUncheckedException(Consts.GENERICPONGEXCP3)
        if (excp == 4) throw UnconstructableException(1, Consts.GENERICPONGEXCP4)
        return "GenericPong director returned"
    }
}

fun fail(msg: String): Nothing {
    throw RuntimeException(msg)
}

fun failif(cond: Boolean, msg: String) {
    if (cond) fail(msg)
}

fun main() {
    try {
        System.loadLibrary("kotlin_director_exception_feature")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val b = Bar(MyFooDirectorImpl())

    // The wrapped exceptions (MyKotlinException1/2/Unexpected) override Throwable.getMessage()
    // to surface their C++ what() string, so e.message works the same as for the pure-Kotlin
    // exceptions reconstructed through generic DirectorException handling.

    try { b.ping(0) } catch (e: Exception) { fail("Exception should not have been thrown: $e from ping(0)") }
    try { b.ping(1); fail("No exception thrown in ping(1)") } catch (e: MyKotlinException1) {
        // Should say "Threw some integer" - Foo::ping throws a "1" which is translated through an int
        failif("Threw some integer" != e.message, "Ping exception not translated through int: '" + e.message + "'")
    }
    try { b.ping(2); fail("No exception thrown in ping(2)") } catch (e: MyKotlinException2) {
        failif(Consts.PINGEXCP2 != e.message, "Expected exception has unexpected message: '" + e.message + "'")
    }

    try { b.pong(0) } catch (e: Exception) { fail("Exception should not have been thrown: $e from pong(0)") }
    try { b.pong(1); fail("No exception thrown in pong(1)") } catch (e: MyKotlinException1) {
        failif(Consts.PONGEXCP1 != e.message, "Expected exception has unexpected message: '" + e.message + "'")
    }
    try { b.pong(2); fail("No exception thrown in pong(2)") } catch (e: MyKotlinException2) {
        failif(Consts.PONGEXCP2 != e.message, "Expected exception has unexpected message: '" + e.message + "'")
    }
    try { b.pong(3); fail("No exception thrown in pong(3)") } catch (e: MyKotlinUnexpected) {
        failif(Consts.PONGUNEXPECTED != e.message, "Expected exception has unexpected message: '" + e.message + "'")
    }
    try { b.pong(4); fail("No exception thrown in pong(4)") } catch (e: MyKotlinUnexpected) {
        failif(Consts.TRANSLATED_NPE != e.message, "Expected exception has unexpected message: '" + e.message + "'")
    }

    try { b.genericpong(0) } catch (e: Exception) { fail("Exception should not have been thrown: $e from genericpong(0)") }
    try { b.genericpong(1); fail("No exception thrown in genericpong(1)") } catch (e: MyKotlinException1) {
        failif(Consts.GENERICPONGEXCP1 != e.message, "Expected exception has unexpected message: '" + e.message + "'")
    }
    try { b.genericpong(2); fail("No exception thrown in genericpong(2)") } catch (e: NewCheckedException) {
        failif(Consts.GENERICPONGEXCP2 != e.message, "Expected exception has unexpected message: '" + e.message + "'")
    }
    try { b.genericpong(3); fail("No exception thrown in genericpong(3)") } catch (e: NewUncheckedException) {
        failif(Consts.GENERICPONGEXCP3 != e.message, "Expected exception has unexpected message: '" + e.message + "'")
    }
    try { b.genericpong(4); fail("No exception thrown in genericpong(4)") } catch (e: RuntimeException) {
        failif(e.javaClass != RuntimeException::class.java, "Exception $e is not exactly RuntimeException")
        failif("Unspecified DirectorException message" != e.message, "Expected exception has unexpected message: '" + e.message + "'")
    }
}

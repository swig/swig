@file:JvmName("director_frob_runme")

import director_frob.*

class PrimsDerived : Prims() {
    override fun ull(i: java.math.BigInteger, j: java.math.BigInteger): java.math.BigInteger {
        return i.subtract(j)
    }
}

fun main() {
    try {
        System.loadLibrary("director_frob")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val foo = Bravo()

    val s = foo.abs_method()
    if (s != "Bravo::abs_method()")
        throw RuntimeException("error")

    val prims: Prims = PrimsDerived()
    val bi = prims.callull(200, 50)
    val biCheck = java.math.BigInteger("150")
    if (bi.compareTo(biCheck) != 0)
        throw RuntimeException("failed got:" + bi)
}

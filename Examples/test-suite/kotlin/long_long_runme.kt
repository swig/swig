@file:JvmName("long_long_runme")

// This is the long_long runtime testcase. It checks that the long long and
// unsigned long long types map correctly to long and BigInteger respectively.

import long_long.*
import java.math.BigInteger

fun check_ll(ll: Long) {
    long_long.ll = ll
    val ll_check = long_long.ll
    if (ll != ll_check) {
        throw RuntimeException("Runtime test using long long failed. ll=" + ll + " ll_check=" + ll_check)
    }
}

fun check_ull(ull: BigInteger) {
    long_long.ull = ull
    val ull_check = long_long.ull
    if (ull.compareTo(ull_check) != 0) {
        throw RuntimeException("Runtime test using unsigned long long failed. ull=" + ull.toString() + " ull_check=" + ull_check.toString())
    }
}

fun main() {
    try {
        System.loadLibrary("long_long")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    check_ll(0L)
    check_ll(0x7FFFFFFFFFFFFFFFL)
    check_ll(-10)

    var testNumber = BigInteger("0")
    val COUNT = 1025

    for (i in 0 until COUNT) {
        check_ull(testNumber)
        testNumber = testNumber.add(BigInteger.ONE)
    }

    testNumber = BigInteger((256 * 256 / 2 - COUNT).toString())
    for (i in 0 until COUNT * 2) {
        check_ull(testNumber)
        testNumber = testNumber.add(BigInteger.ONE)
    }

    testNumber = BigInteger((256 * 256 - COUNT).toString())
    for (i in 0 until COUNT * 2) {
        check_ull(testNumber)
        testNumber = testNumber.add(BigInteger.ONE)
    }

    testNumber = BigInteger((0x7FFFFFFFFFFFFFFFL - COUNT).toString())
    for (i in 0 until COUNT * 2) {
        check_ull(testNumber)
        testNumber = testNumber.add(BigInteger.ONE)
    }

    testNumber = BigInteger("18446744073709551615") //0xFFFFFFFFFFFFFFFFL
    testNumber = testNumber.add(BigInteger.valueOf((1 - COUNT).toLong()))
    for (i in 0 until COUNT) {
        check_ull(testNumber)
        testNumber = testNumber.add(BigInteger.ONE)
    }

    try {
        val nullArg: BigInteger? = null
        long_long.ull = nullArg!!
        throw RuntimeException("null check failed")
    } catch (e: NullPointerException) {
    }

    // UnsignedToSigned - checks that a cast from unsigned long long to long long in C
    // gives expected value (including -ve numbers)

    val nums = longArrayOf(
        0x00,
        0xFF, 0x80, 0x7F, 0x01,
        -0xFF, -0x80, -0x7F, -0x01,
        0x100, 0x10000,
        -0x100, -0x10000,
        0xFFFF, 0xFF80, 0xFF7F, 0xFF01, 0xFF00,
        -0xFFFF, -0xFF80, -0xFF7F, -0xFF01, -0xFF00,
        0x7FFF, 0x7F80, 0x7F7F, 0x7F01, 0x7F00,
        -0x7FFF, -0x7F80, -0x7F7F, -0x7F01, -0x7F00,
        0x80FF, 0x8080, 0x807F, 0x8001, 0x8000,
        -0x80FF, -0x8080, -0x807F, -0x8001, -0x8000,
        Int.MAX_VALUE.toLong(), Int.MIN_VALUE.toLong(),
        Int.MAX_VALUE.toLong() + 1, Int.MIN_VALUE.toLong() - 1,
        Long.MAX_VALUE, Long.MIN_VALUE,
    )

    val bigIntegers = ArrayList<BigInteger>()
    for (i in nums.indices) {
        val bi = BigInteger(java.lang.Long.valueOf(nums[i]).toString())
        bigIntegers.add(bi)
    }

    run {
        var bi = BigInteger(java.lang.Long.valueOf(Long.MAX_VALUE).toString())
        bigIntegers.add(bi.add(BigInteger.ONE))
        bi = BigInteger(java.lang.Long.valueOf(Long.MIN_VALUE).toString())
        bigIntegers.add(bi.subtract(BigInteger.ONE))
    }

    var failed = false
    for (i in bigIntegers.indices) {
        val bi = bigIntegers[i]
        val longReturn = long_long.UnsignedToSigned(bi)
        if (bi.toLong() != longReturn) {
            System.err.println("Conversion to long failed, in:" + bi + " out:" + longReturn)
            failed = true
        }
    }
    if (failed)
        throw RuntimeException("There were UnsignedToSigned failures")
}

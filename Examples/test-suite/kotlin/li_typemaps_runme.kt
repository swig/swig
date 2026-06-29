@file:JvmName("li_typemaps_runme")

// Check a few of the INPUT, OUTPUT and INOUT typemaps.

import li_typemaps.*
import java.math.BigInteger

fun exit_test(funcName: String) {
    throw RuntimeException("Test FAILED in function " + funcName)
}

fun main() {
    try {
        System.loadLibrary("li_typemaps")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Check double INPUT typemaps
    if (li_typemaps.in_double(22.22) != 22.22) exit_test("in_double")
    if (li_typemaps.inr_double(22.22) != 22.22) exit_test("inr_double")

    // Check double OUTPUT typemaps
    run {
        val v = doubleArrayOf(44.44)
        li_typemaps.out_double(22.22, v)
        if (v[0] != 22.22) exit_test("out_double")
    }
    run {
        val v = doubleArrayOf(44.44)
        li_typemaps.outr_double(22.22, v)
        if (v[0] != 22.22) exit_test("outr_double")
    }
    try {
        val v: DoubleArray? = null
        li_typemaps.out_double(22.22, v!!)
        exit_test("null out_double")
    } catch (e: NullPointerException) {
    }

    // Check double INOUT typemaps
    run {
        val v = doubleArrayOf(44.44)
        li_typemaps.inout_double(v)
        if (v[0] != 44.44) exit_test("inout_double")
    }
    run {
        val v = doubleArrayOf(44.44)
        li_typemaps.inoutr_double(v)
        if (v[0] != 44.44) exit_test("inoutr_double")
    }
    try {
        val v: DoubleArray? = null
        li_typemaps.inout_double(v!!)
        exit_test("null inout_double")
    } catch (e: NullPointerException) {
    }

    // Check unsigned long long INPUT typemaps
    val forty = BigInteger("40")
    val twenty = BigInteger("20")
    if (li_typemaps.in_ulonglong(twenty) != twenty) exit_test("in_ulonglong")
    if (li_typemaps.inr_ulonglong(twenty) != twenty) exit_test("inr_ulonglong")

    try {
        val nullArg: BigInteger? = null
        li_typemaps.in_ulonglong(nullArg!!)
        exit_test("null in_ulonglong")
    } catch (e: NullPointerException) {
    }

    // Check unsigned long long OUTPUT typemaps
    run {
        val v = arrayOf(BigInteger("40"))
        li_typemaps.out_ulonglong(twenty, v)
        if (v[0] != twenty) exit_test("out_ulonglong")
    }
    run {
        val v = arrayOf(BigInteger("40"))
        li_typemaps.outr_ulonglong(twenty, v)
        if (v[0] != twenty) exit_test("outr_ulonglong")
    }
    try {
        @Suppress("UNCHECKED_CAST")
        val v = null as Array<BigInteger>?
        li_typemaps.out_ulonglong(twenty, v!!)
        exit_test("null out_ulonglong")
    } catch (e: NullPointerException) {
    }
    run {
        @Suppress("UNCHECKED_CAST")
        val v = arrayOfNulls<BigInteger>(1) as Array<BigInteger>
        li_typemaps.out_ulonglong(twenty, v)
        if (v[0] != twenty) exit_test("null element out_ulonglong")
    }

    // Check unsigned long long INOUT typemaps
    run {
        val v = arrayOf(BigInteger("40"))
        li_typemaps.inout_ulonglong(v)
        if (v[0] != forty) exit_test("inout_ulonglong")
    }
    run {
        val v = arrayOf(BigInteger("40"))
        li_typemaps.inoutr_ulonglong(v)
        if (v[0] != forty) exit_test("inoutr_ulonglong")
    }
    try {
        @Suppress("UNCHECKED_CAST")
        val v = null as Array<BigInteger>?
        li_typemaps.inout_ulonglong(v!!)
        exit_test("null inout_ulonglong")
    } catch (e: NullPointerException) {
    }
    try {
        @Suppress("UNCHECKED_CAST")
        val v = arrayOfNulls<BigInteger>(1) as Array<BigInteger>
        li_typemaps.inout_ulonglong(v)
        exit_test("null element inout_ulonglong")
    } catch (e: NullPointerException) {
    }
}

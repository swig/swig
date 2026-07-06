@file:JvmName("unions_runme")

// This is the union runtime testcase. It ensures that values within a
// union embedded within a struct can be set and read correctly.

import unions.*

fun main() {
    try {
        System.loadLibrary("unions")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Create new instances of SmallStruct and BigStruct for later use
    val small = SmallStruct()
    small.jill = 200.toShort()

    val big = BigStruct()
    big.smallstruct = small
    big.jack = 300

    // Use SmallStruct then BigStruct to setup EmbeddedUnionTest.
    // Ensure values in EmbeddedUnionTest are set correctly for each.
    val eut = EmbeddedUnionTest()

    // First check the SmallStruct in EmbeddedUnionTest
    eut.number = 1
    eut.uni!!.small = small
    val Jill1 = eut.uni!!.small!!.jill
    if (Jill1.toInt() != 200) {
        throw RuntimeException("Runtime test1 failed. eut.uni.small.jill=" + Jill1)
    }

    val Num1 = eut.number
    if (Num1 != 1) {
        throw RuntimeException("Runtime test2 failed. eut.number=" + Num1)
    }

    // Secondly check the BigStruct in EmbeddedUnionTest
    eut.number = 2
    eut.uni!!.big = big
    val Jack1 = eut.uni!!.big!!.jack
    if (Jack1 != 300) {
        throw RuntimeException("Runtime test3 failed. eut.uni.big.jack=" + Jack1)
    }

    val Jill2 = eut.uni!!.big!!.smallstruct!!.jill
    if (Jill2.toInt() != 200) {
        throw RuntimeException("Runtime test4 failed. eut.uni.big.smallstruct.jill=" + Jill2)
    }

    val Num2 = eut.number
    if (Num2 != 2) {
        throw RuntimeException("Runtime test5 failed. eut.number=" + Num2)
    }
}

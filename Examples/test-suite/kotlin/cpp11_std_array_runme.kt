@file:JvmName("cpp11_std_array_runme")

import cpp11_std_array.*

fun toArray6(a: IntArray): ArrayInt6 {
    val ai = ArrayInt6()
    if (a.size != 6)
        throw RuntimeException("a is incorrect size")
    for (i in 0 until 6)
        ai.set(i, a[i])
    return ai
}

fun compareContainers(actual: ArrayInt6, expected: IntArray) {
    if (actual.size() != expected.size)
        throw RuntimeException("Sizes are different: " + actual.size() + " " + expected.size)
    for (i in 0 until actual.size()) {
        val actualValue = actual.get(i)
        val expectedValue = expected[i]
        if (actualValue != expectedValue)
            throw RuntimeException("Value is wrong for element " + i + ". Expected " + expectedValue + " got: " + actualValue)
    }
    if (actual.isEmpty())
        throw RuntimeException("ai should not be empty")
}

fun main() {
    try {
        System.loadLibrary("cpp11_std_array")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    var ai = ArrayInt6()
    compareContainers(ai, intArrayOf(0, 0, 0, 0, 0, 0))

    val vals = intArrayOf(10, 20, 30, 40, 50, 60)
    for (i in 0 until ai.size())
        ai.set(i, vals[i])
    compareContainers(ai, vals)

    // Check return
    compareContainers(cpp11_std_array.arrayOutVal(), intArrayOf(-2, -1, 0, 0, 1, 2))
    compareContainers(cpp11_std_array.arrayOutConstRef(), intArrayOf(-2, -1, 0, 0, 1, 2))
    compareContainers(cpp11_std_array.arrayOutRef(), intArrayOf(-2, -1, 0, 0, 1, 2))
    compareContainers(cpp11_std_array.arrayOutPtr()!!, intArrayOf(-2, -1, 0, 0, 1, 2))

    // Check passing arguments
    ai = cpp11_std_array.arrayInVal(toArray6(intArrayOf(9, 8, 7, 6, 5, 4)))
    compareContainers(ai, intArrayOf(90, 80, 70, 60, 50, 40))

    ai = cpp11_std_array.arrayInConstRef(toArray6(intArrayOf(9, 8, 7, 6, 5, 4)))
    compareContainers(ai, intArrayOf(90, 80, 70, 60, 50, 40))

    ai = ArrayInt6(toArray6(intArrayOf(9, 8, 7, 6, 5, 4)))
    cpp11_std_array.arrayInRef(ai)
    compareContainers(ai, intArrayOf(90, 80, 70, 60, 50, 40))

    ai = ArrayInt6(toArray6(intArrayOf(9, 8, 7, 6, 5, 4)))
    cpp11_std_array.arrayInPtr(ai)
    compareContainers(ai, intArrayOf(90, 80, 70, 60, 50, 40))

    // fill
    ai.fill(111)
    compareContainers(ai, intArrayOf(111, 111, 111, 111, 111, 111))

    // out of range errors
    try {
        ai.set(ai.size(), 0)
        throw RuntimeException("Out of range exception not caught")
    } catch (e: IndexOutOfBoundsException) {
    }
    try {
        ai.set(-1, 0)
        throw RuntimeException("Out of range exception not caught")
    } catch (e: IndexOutOfBoundsException) {
    }
}

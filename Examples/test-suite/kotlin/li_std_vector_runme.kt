@file:JvmName("li_std_vector_runme")

import li_std_vector.*

fun checkThat(mustBeTrue: Boolean) {
    if (!mustBeTrue) {
        throw RuntimeException("Test failed at line number " + Thread.currentThread().stackTrace[2].lineNumber)
    }
}

fun main() {
    try {
        System.loadLibrary("li_std_vector")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val v1 = li_std_vector.vecintptr(IntVector())

    checkThat(v1.isEmpty())
    checkThat(v1.size == 0)
    checkThat(v1.add(123))
    checkThat(v1.size == 1)
    checkThat(!v1.isEmpty())

    var sum = 0
    for (n in v1) {
        checkThat(n == 123)
        sum += n
    }
    checkThat(sum == 123)
    checkThat(v1[0] == 123)
    v1.clear()
    checkThat(v1.isEmpty())
    v1.add(123)

    checkThat(v1.set(0, 456) == 123)
    checkThat(v1.size == 1)
    checkThat(v1[0] == 456)

    val v1Iterator = v1.iterator()
    checkThat(v1Iterator.hasNext())
    checkThat(v1Iterator.next() == 456)
    checkThat(!v1Iterator.hasNext())

    checkThat(!v1.remove(123))
    checkThat(v1.remove(456))
    checkThat(v1.isEmpty())

    // Constructing from elements and modifying through the list interface
    val v4 = DoubleVector(arrayOf(1.0, 2.0, 3.0))
    checkThat(v4.size == 3)
    v4.add(1, 1.5)
    checkThat(v4.size == 4)
    checkThat(v4[1] == 1.5)
    checkThat(v4.removeAt(1) == 1.5)
    checkThat(v4.size == 3)

    // Vector of class instances
    val sv = StructVector()
    sv.add(Struct(1.5))
    checkThat(sv.size == 1)
    checkThat(sv[0].num == 1.5)
}

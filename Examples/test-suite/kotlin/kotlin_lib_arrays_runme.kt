@file:JvmName("kotlin_lib_arrays_runme")

// This is the kotlin_lib_arrays runtime testcase. It ensures that a getter and a setter has
// been produced for array members and that they function as expected. It tests the Kotlin
// primitive array library typemaps (ByteArray/ShortArray/IntArray/LongArray/FloatArray/
// DoubleArray and the ARRAYSOFENUMS IntArray typemaps) as well as the JAVA_ARRAYSOFCLASSES
// feature, which maps C arrays of wrapped structs to Array<ProxyClass>. Mirrors
// java_lib_arrays_runme.

import kotlin_lib_arrays.*

fun checkByteArray(original: ByteArray, checking: ByteArray) {
    for (i in original.indices) {
        if (checking[i] != original[i]) throw RuntimeException("Runtime test failed. checking[$i]=${checking[i]}")
    }
}

fun checkShortArray(original: ShortArray, checking: ShortArray) {
    for (i in original.indices) {
        if (checking[i] != original[i]) throw RuntimeException("Runtime test failed. checking[$i]=${checking[i]}")
    }
}

fun checkIntArray(original: IntArray, checking: IntArray) {
    for (i in original.indices) {
        if (checking[i] != original[i]) throw RuntimeException("Runtime test failed. checking[$i]=${checking[i]}")
    }
}

fun checkLongArray(original: LongArray, checking: LongArray) {
    for (i in original.indices) {
        if (checking[i] != original[i]) throw RuntimeException("Runtime test failed. checking[$i]=${checking[i]}")
    }
}

fun checkFloatArray(original: FloatArray, checking: FloatArray) {
    for (i in original.indices) {
        if (checking[i] != original[i]) throw RuntimeException("Runtime test failed. checking[$i]=${checking[i]}")
    }
}

fun checkDoubleArray(original: DoubleArray, checking: DoubleArray) {
    for (i in original.indices) {
        if (checking[i] != original[i]) throw RuntimeException("Runtime test failed. checking[$i]=${checking[i]}")
    }
}

fun checkStructArray(original: Array<SimpleStruct>, checking: Array<SimpleStruct>) {
    for (i in original.indices) {
        if (checking[i].double_field != original[i].double_field)
            throw RuntimeException("Runtime test failed. checking[$i].double_field=${checking[i].double_field}")
    }
}

fun main() {
    try {
        System.loadLibrary("kotlin_lib_arrays")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Arrays of wrapped classes (JAVA_ARRAYSOFCLASSES) -> Array<ProxyClass>
    val array_struct = arrayOf(SimpleStruct(), SimpleStruct())
    array_struct[0].double_field = 222.333
    array_struct[1].double_field = 444.555

    val array_another_struct = arrayOf(AnotherStruct(), AnotherStruct())
    array_another_struct[0].simple = array_struct[0]
    array_another_struct[1].simple = array_struct[1]
    if (array_another_struct[0].simple!!.double_field != 222.333) throw RuntimeException("AnotherStruct[0] failed")
    if (array_another_struct[1].simple!!.double_field != 444.555) throw RuntimeException("AnotherStruct[1] failed")

    val array_yet_another_struct = arrayOf(YetAnotherStruct(), YetAnotherStruct())
    array_yet_another_struct[0].simple = array_struct[0]
    array_yet_another_struct[1].simple = array_struct[1]

    if (kotlin_lib_arrays.extract_ptr(array_yet_another_struct, 0) != 222.333) throw RuntimeException("extract_ptr 0 failed")
    if (kotlin_lib_arrays.extract_ptr(array_yet_another_struct, 1) != 444.555) throw RuntimeException("extract_ptr 1 failed")

    kotlin_lib_arrays.modifyYAS(array_yet_another_struct, array_yet_another_struct.size)
    for (i in 0 until 2) {
        if (array_yet_another_struct[i].simple!!.double_field != array_struct[i].double_field * 10.0)
            throw RuntimeException("modifyYAS failed")
    }

    // Check array member variables
    val arrayStruct = ArrayStruct()

    // Create arrays for all the primitive array types that ArrayStruct can handle
    val array_c = "X"
    val array_c_extra = byteArrayOf(11, 22)
    val array_sc = byteArrayOf(10, 20)
    val array_uc = shortArrayOf(101, 201)
    val array_s = shortArrayOf(1002, 2002)
    val array_us = intArrayOf(1003, 2003)
    val array_i = intArrayOf(1004, 2004)
    val array_ui = longArrayOf(1005, 2005)
    val array_l = intArrayOf(1006, 2006)
    val array_ul = longArrayOf(1007, 2007)
    val array_ll = longArrayOf(1008, 2008)
    val array_f = floatArrayOf(1009.1f, 2009.1f)
    val array_d = doubleArrayOf(1010.2, 2010.2)
    val array_finger = intArrayOf(finger.Three, finger.Four)
    val array_toe = intArrayOf(toe.Big, toe.Little)

    kotlin_lib_arrays.toestest(array_toe, array_toe, array_toe)

    // Now set the array members and check that they have been set correctly
    arrayStruct.array_c = array_c
    if (arrayStruct.array_c != array_c) throw RuntimeException("Runtime test failed. array_c=[${arrayStruct.array_c}]")

    arrayStruct.array_sc = array_sc
    checkByteArray(array_sc, arrayStruct.array_sc)

    arrayStruct.array_uc = array_uc
    checkShortArray(array_uc, arrayStruct.array_uc)

    arrayStruct.array_s = array_s
    checkShortArray(array_s, arrayStruct.array_s)

    arrayStruct.array_us = array_us
    checkIntArray(array_us, arrayStruct.array_us)

    arrayStruct.array_i = array_i
    checkIntArray(array_i, arrayStruct.array_i)

    arrayStruct.array_ui = array_ui
    checkLongArray(array_ui, arrayStruct.array_ui)

    arrayStruct.array_l = array_l
    checkIntArray(array_l, arrayStruct.array_l)

    arrayStruct.array_ul = array_ul
    checkLongArray(array_ul, arrayStruct.array_ul)

    arrayStruct.array_ll = array_ll
    checkLongArray(array_ll, arrayStruct.array_ll)

    arrayStruct.array_f = array_f
    checkFloatArray(array_f, arrayStruct.array_f)

    arrayStruct.array_d = array_d
    checkDoubleArray(array_d, arrayStruct.array_d)

    arrayStruct.array_enum = array_finger
    checkIntArray(array_finger, arrayStruct.array_enum)

    arrayStruct.array_struct = array_struct
    checkStructArray(array_struct, arrayStruct.array_struct)

    // Extended element (for char[])
    val ase = ArrayStructExtra()
    ase.array_c2 = array_c_extra
    checkByteArray(array_c_extra, ase.array_c2)
}

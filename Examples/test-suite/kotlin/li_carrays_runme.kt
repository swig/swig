@file:JvmName("li_carrays_runme")

import li_carrays.*

fun assertEq(val1: Int, val2: Int) {
    if (val1 != val2)
        throw RuntimeException("Mismatch. val1=" + val1 + " val2=" + val2)
}

fun main() {
    try {
        System.loadLibrary("li_carrays")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // array_class
    run {
        val length = 5
        val xyArray = XYArray(length.toLong())
        for (i in 0 until length) {
            val xy = xyArray.getitem(i.toLong())
            xy.x = i * 10
            xy.y = i * 100
            xyArray.setitem(i.toLong(), xy)
        }
        for (i in 0 until length) {
            assertEq(xyArray.getitem(i.toLong()).x, i * 10)
            assertEq(xyArray.getitem(i.toLong()).y, i * 100)
        }
    }

    run {
        // global array variable
        val length = 3
        val xyArrayPointer = li_carrays.globalXYArray
        val xyArray = XYArray.frompointer(xyArrayPointer)!!
        for (i in 0 until length) {
            val xy = xyArray.getitem(i.toLong())
            xy.x = i * 10
            xy.y = i * 100
            xyArray.setitem(i.toLong(), xy)
        }
        for (i in 0 until length) {
            assertEq(xyArray.getitem(i.toLong()).x, i * 10)
            assertEq(xyArray.getitem(i.toLong()).y, i * 100)
        }
    }

    // array_functions
    run {
        val length = 5
        val abArray = li_carrays.new_ABArray(length.toLong())
        for (i in 0 until length) {
            val ab = li_carrays.ABArray_getitem(abArray, i.toLong())
            ab.a = i * 10
            ab.b = i * 100
            li_carrays.ABArray_setitem(abArray, i.toLong(), ab)
        }
        for (i in 0 until length) {
            assertEq(li_carrays.ABArray_getitem(abArray, i.toLong()).a, i * 10)
            assertEq(li_carrays.ABArray_getitem(abArray, i.toLong()).b, i * 100)
        }
        li_carrays.delete_ABArray(abArray)
    }

    run {
        // global array variable
        val length = 3
        val abArray = li_carrays.globalABArray
        for (i in 0 until length) {
            val ab = li_carrays.ABArray_getitem(abArray, i.toLong())
            ab.a = i * 10
            ab.b = i * 100
            li_carrays.ABArray_setitem(abArray, i.toLong(), ab)
        }
        for (i in 0 until length) {
            assertEq(li_carrays.ABArray_getitem(abArray, i.toLong()).a, i * 10)
            assertEq(li_carrays.ABArray_getitem(abArray, i.toLong()).b, i * 100)
        }
    }
}

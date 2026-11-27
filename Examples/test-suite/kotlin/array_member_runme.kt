@file:JvmName("array_member_runme")

import array_member.*

fun main() {
    try {
        System.loadLibrary("array_member")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val f = Foo()
    f.data = array_member.global_data

    for (i in 0 until 8) {
        if (array_member.get_value(f.data, i) != array_member.get_value(array_member.global_data, i))
            throw RuntimeException("Bad array assignment")
    }

    for (i in 0 until 8) {
        array_member.set_value(f.data, i, -i)
    }

    array_member.global_data = f.data

    for (i in 0 until 8) {
        if (array_member.get_value(f.data, i) != array_member.get_value(array_member.global_data, i))
            throw RuntimeException("Bad array assignment")
    }
}

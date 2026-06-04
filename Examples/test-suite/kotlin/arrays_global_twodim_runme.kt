@file:JvmName("arrays_global_twodim_runme")

import arrays_global_twodim.*

fun main() {
    try {
        System.loadLibrary("arrays_global_twodim")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val constintarray2d = arrays_global_twodim.array_const_i
    val intarray2d = arrays_global_twodim.array_i

    // Set all the non const int array members from the const int array members and check
    arrays_global_twodim.array_i = constintarray2d

    var count = 10
    for (x in 0 until arrays_global_twodim.ARRAY_LEN_X) {
        for (y in 0 until arrays_global_twodim.ARRAY_LEN_Y) {
            if (arrays_global_twodim.get_2d_array(intarray2d, x, y) != count++) {
                throw RuntimeException("Value incorrect array_i[$x][$y]")
            }
        }
    }
}

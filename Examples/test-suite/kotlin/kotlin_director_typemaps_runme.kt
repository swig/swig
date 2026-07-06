@file:JvmName("kotlin_director_typemaps_runme")

// Test director reference typemaps in typemaps.i - similar to java_director_typemaps_ptr.i testcase

import kotlin_director_typemaps.*

class kotlin_director_typemaps_MyQuux : Quux() {
    override fun director_method_output(
        bool_arg: BooleanArray?,

        signed_char_arg: ByteArray?,
        unsigned_char_arg: ShortArray?,

        short_arg: ShortArray?,
        unsigned_short_arg: IntArray?,

        int_arg: IntArray?,
        unsigned_int_arg: LongArray?,

        long_arg: IntArray?,
        unsigned_long_arg: LongArray?,

        long_long_arg: LongArray?,
        // unsigned_long_long_arg: Array<java.math.BigInteger>,

        float_arg: FloatArray?,
        double_arg: DoubleArray?)
    {
        bool_arg!![0] = true
        signed_char_arg!![0] = 1
        unsigned_char_arg!![0] = 2
        short_arg!![0] = 3
        unsigned_short_arg!![0] = 4
        int_arg!![0] = 5
        unsigned_int_arg!![0] = 6
        long_arg!![0] = 7
        unsigned_long_arg!![0] = 8
        long_long_arg!![0] = 9
        // unsigned_long_long_arg[0] = 10
        float_arg!![0] = 11f
        double_arg!![0] = 12.0
    }

    override fun director_method_inout(
        bool_arg: BooleanArray?,

        signed_char_arg: ByteArray?,
        unsigned_char_arg: ShortArray?,

        short_arg: ShortArray?,
        unsigned_short_arg: IntArray?,

        int_arg: IntArray?,
        unsigned_int_arg: LongArray?,

        long_arg: IntArray?,
        unsigned_long_arg: LongArray?,

        long_long_arg: LongArray?,
        // unsigned_long_long_arg: Array<java.math.BigInteger>,

        float_arg: FloatArray?,
        double_arg: DoubleArray?)
    {
        if (bool_arg!![0]) throw RuntimeException("unexpected value for bool_arg")

        if (signed_char_arg!![0].toInt() != 101) throw RuntimeException("unexpected value for signed_char_arg")
        if (unsigned_char_arg!![0].toInt() != 101) throw RuntimeException("unexpected value for unsigned_char_arg")
        if (short_arg!![0].toInt() != 101) throw RuntimeException("unexpected value for short_arg")
        if (unsigned_short_arg!![0] != 101) throw RuntimeException("unexpected value for unsigned_short_arg")
        if (int_arg!![0] != 101) throw RuntimeException("unexpected value for int_arg")
        if (unsigned_int_arg!![0] != 101L) throw RuntimeException("unexpected value for unsigned_int_arg")
        if (long_arg!![0] != 101) throw RuntimeException("unexpected value for long_arg")
        if (unsigned_long_arg!![0] != 101L) throw RuntimeException("unexpected value for unsigned_long_arg")
        if (long_long_arg!![0] != 101L) throw RuntimeException("unexpected value for long_long_arg")
        // if (unsigned_long_long_arg[0] != 101) throw RuntimeException("unexpected value for unsigned_long_long_arg")
        if (float_arg!![0] != 101f) throw RuntimeException("unexpected value for float_arg")
        if (double_arg!![0] != 101.0) throw RuntimeException("unexpected value for double_arg")

        bool_arg!![0] = false
        signed_char_arg!![0] = 11
        unsigned_char_arg!![0] = 12
        short_arg!![0] = 13
        unsigned_short_arg!![0] = 14
        int_arg!![0] = 15
        unsigned_int_arg!![0] = 16
        long_arg!![0] = 17
        unsigned_long_arg!![0] = 18
        long_long_arg!![0] = 19
        // unsigned_long_long_arg[0] = 110
        float_arg!![0] = 111f
        double_arg!![0] = 112.0
    }

    override fun director_method_nameless_args(
        bool_arg: BooleanArray?,

        signed_char_arg: ByteArray?,
        unsigned_char_arg: ShortArray?,

        short_arg: ShortArray?,
        unsigned_short_arg: IntArray?,

        int_arg: IntArray?,
        unsigned_int_arg: LongArray?,

        long_arg: IntArray?,
        unsigned_long_arg: LongArray?,

        long_long_arg: LongArray?,
        // unsigned_long_long_arg: Array<java.math.BigInteger>,

        float_arg: FloatArray?,
        double_arg: DoubleArray?)
    {
        bool_arg!![0] = true
        signed_char_arg!![0] = 12
        unsigned_char_arg!![0] = 13
        short_arg!![0] = 14
        unsigned_short_arg!![0] = 15
        int_arg!![0] = 16
        unsigned_int_arg!![0] = 17
        long_arg!![0] = 18
        unsigned_long_arg!![0] = 19
        long_long_arg!![0] = 20
        // unsigned_long_long_arg[0] = 111
        float_arg!![0] = 112f
        double_arg!![0] = 113.0
    }
}

fun main() {
    try {
        System.loadLibrary("kotlin_director_typemaps")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val quux: Quux = kotlin_director_typemaps_MyQuux()
    quux.etest()
}

@file:JvmName("java_director_typemaps_runme")

// Test director reference typemaps in typemaps.i - similar to java_director_typemaps_ptr.i testcase

import java_director_typemaps.*

class java_director_typemaps_MyQuux : Quux() {
    override fun director_method_output(
        boolarg_output: BooleanArray?,

        signed_chararg_output: ByteArray?,
        unsigned_chararg_output: ShortArray?,

        shortarg_output: ShortArray?,
        unsigned_shortarg_output: IntArray?,

        intarg_output: IntArray?,
        unsigned_intarg_output: LongArray?,

        longarg_output: IntArray?,
        unsigned_longarg_output: LongArray?,

        long_longarg_output: LongArray?,
        // unsigned_long_long_arg: Array<java.math.BigInteger>,

        floatarg_output: FloatArray?,
        doublearg_output: DoubleArray?)
    {
        boolarg_output!![0] = true
        signed_chararg_output!![0] = 1
        unsigned_chararg_output!![0] = 2
        shortarg_output!![0] = 3
        unsigned_shortarg_output!![0] = 4
        intarg_output!![0] = 5
        unsigned_intarg_output!![0] = 6
        longarg_output!![0] = 7
        unsigned_longarg_output!![0] = 8
        long_longarg_output!![0] = 9
        // unsigned_long_long_arg[0] = 10
        floatarg_output!![0] = 11f
        doublearg_output!![0] = 12.0
    }

    override fun director_method_inout(
        boolarg_inout: BooleanArray?,

        signed_chararg_inout: ByteArray?,
        unsigned_chararg_inout: ShortArray?,

        shortarg_inout: ShortArray?,
        unsigned_shortarg_inout: IntArray?,

        intarg_inout: IntArray?,
        unsigned_intarg_inout: LongArray?,

        longarg_inout: IntArray?,
        unsigned_longarg_inout: LongArray?,

        long_longarg_inout: LongArray?,
        // unsigned_long_long_arg: Array<java.math.BigInteger>,

        floatarg_inout: FloatArray?,
        doublearg_inout: DoubleArray?)
    {
        if (boolarg_inout!![0]) throw RuntimeException("unexpected value for boolarg_inout")

        if (signed_chararg_inout!![0].toInt() != 101) throw RuntimeException("unexpected value for signed_chararg_inout")
        if (unsigned_chararg_inout!![0].toInt() != 101) throw RuntimeException("unexpected value for unsigned_chararg_inout")
        if (shortarg_inout!![0].toInt() != 101) throw RuntimeException("unexpected value for shortarg_inout")
        if (unsigned_shortarg_inout!![0] != 101) throw RuntimeException("unexpected value for unsigned_shortarg_inout")
        if (intarg_inout!![0] != 101) throw RuntimeException("unexpected value for intarg_inout")
        if (unsigned_intarg_inout!![0] != 101L) throw RuntimeException("unexpected value for unsigned_intarg_inout")
        if (longarg_inout!![0] != 101) throw RuntimeException("unexpected value for longarg_inout")
        if (unsigned_longarg_inout!![0] != 101L) throw RuntimeException("unexpected value for unsigned_longarg_inout")
        if (long_longarg_inout!![0] != 101L) throw RuntimeException("unexpected value for long_longarg_inout")
        // if (unsigned_long_long_arg[0] != 101) throw RuntimeException("unexpected value for unsigned_long_long_arg")
        if (floatarg_inout!![0] != 101f) throw RuntimeException("unexpected value for floatarg_inout")
        if (doublearg_inout!![0] != 101.0) throw RuntimeException("unexpected value for doublearg_inout")

        boolarg_inout[0] = false
        signed_chararg_inout[0] = 11
        unsigned_chararg_inout[0] = 12
        shortarg_inout[0] = 13
        unsigned_shortarg_inout[0] = 14
        intarg_inout[0] = 15
        unsigned_intarg_inout[0] = 16
        longarg_inout[0] = 17
        unsigned_longarg_inout[0] = 18
        long_longarg_inout[0] = 19
        // unsigned_long_long_arg[0] = 110
        floatarg_inout[0] = 111f
        doublearg_inout[0] = 112.0
    }

    @Suppress("PARAMETER_NAME_CHANGED_ON_OVERRIDE")
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
        System.loadLibrary("java_director_typemaps")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val quux: Quux = java_director_typemaps_MyQuux()
    quux.etest()
}

@file:JvmName("primitive_ref_runme")

import primitive_ref.*
import java.math.BigInteger

fun main() {
    try {
        System.loadLibrary("primitive_ref")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    if (primitive_ref.ref_int(3) != 3) {
        throw RuntimeException("ref_int failed!")
    }
    if (primitive_ref.ref_uint(3) != 3L) {
        throw RuntimeException("ref_uint failed!")
    }
    if (primitive_ref.ref_short(3.toShort()).toInt() != 3) {
        throw RuntimeException("ref_short failed!")
    }
    if (primitive_ref.ref_ushort(3) != 3) {
        throw RuntimeException("ref_ushort failed!")
    }
    if (primitive_ref.ref_long(3) != 3) {
        throw RuntimeException("ref_long failed!")
    }
    if (primitive_ref.ref_ulong(3) != 3L) {
        throw RuntimeException("ref_ulong failed!")
    }
    if (primitive_ref.ref_schar(3.toByte()).toInt() != 3) {
        throw RuntimeException("ref_schar failed!")
    }
    if (primitive_ref.ref_uchar(3.toShort()).toInt() != 3) {
        throw RuntimeException("ref_uchar failed!")
    }
    if (primitive_ref.ref_bool(true) != true) {
        throw RuntimeException("ref_bool failed!")
    }
    if (primitive_ref.ref_float(3.5.toFloat()) != 3.5f) {
        throw RuntimeException("ref_float failed!")
    }
    if (primitive_ref.ref_double(3.5) != 3.5) {
        throw RuntimeException("ref_double failed!")
    }
    if (primitive_ref.ref_char('x') != 'x') {
        throw RuntimeException("ref_char failed!")
    }
    if (primitive_ref.ref_longlong(0x123456789ABCDEF0L) != 0x123456789ABCDEF0L) {
        throw RuntimeException("ref_longlong failed!")
    }
    val bi = BigInteger("18446744073709551615")
    if (bi.compareTo(primitive_ref.ref_ulonglong(bi)) != 0) {
        throw RuntimeException("ref_ulonglong failed!")
    }
}

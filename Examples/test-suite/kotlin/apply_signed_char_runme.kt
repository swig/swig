@file:JvmName("apply_signed_char_runme")

import apply_signed_char.*

fun main() {
    try {
        System.loadLibrary("apply_signed_char")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val smallnum: Byte = -127
    if (apply_signed_char.CharValFunction(smallnum) != smallnum) throw RuntimeException("failed")
    if (apply_signed_char.CCharValFunction(smallnum) != smallnum) throw RuntimeException("failed")
    if (apply_signed_char.CCharRefFunction(smallnum) != smallnum) throw RuntimeException("failed")

    apply_signed_char.globalchar = smallnum
    if (apply_signed_char.globalchar != smallnum) throw RuntimeException("failed")
    if (apply_signed_char.globalconstchar.toInt() != -110) throw RuntimeException("failed")

    val d = DirectorTest()
    if (d.CharValFunction(smallnum) != smallnum) throw RuntimeException("failed")
    if (d.CCharValFunction(smallnum) != smallnum) throw RuntimeException("failed")
    if (d.CCharRefFunction(smallnum) != smallnum) throw RuntimeException("failed")

    d.memberchar = smallnum
    if (d.memberchar != smallnum) throw RuntimeException("failed")
    if (d.memberconstchar.toInt() != -112) throw RuntimeException("failed")
}

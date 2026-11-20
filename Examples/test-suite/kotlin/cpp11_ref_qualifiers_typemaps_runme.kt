@file:JvmName("cpp11_ref_qualifiers_typemaps_runme")

import cpp11_ref_qualifiers_typemaps.*

fun main() {
    try {
        System.loadLibrary("cpp11_ref_qualifiers_typemaps")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    run {
        val tm = TypemapsNamedParms()
        if (tm.fff(cpp11_ref_qualifiers_typemaps.FF1_MFP).toInt() != 2)
            throw RuntimeException("failed")
        if (tm.ccc(cpp11_ref_qualifiers_typemaps.CC4_MFP).toInt() != 5)
            throw RuntimeException("failed")
        if (tm.ggg(cpp11_ref_qualifiers_typemaps.GG7_MFP).toInt() != 8)
            throw RuntimeException("failed")
        if (tm.hhh(cpp11_ref_qualifiers_typemaps.HH10_MFP).toInt() != 11)
            throw RuntimeException("failed")
    }
    run {
        val tm = TypemapsUnnamedParms()
        if (tm.fff(cpp11_ref_qualifiers_typemaps.FF1_MFP).toInt() != 3)
            throw RuntimeException("failed")
        if (tm.ccc(cpp11_ref_qualifiers_typemaps.CC4_MFP).toInt() != 6)
            throw RuntimeException("failed")
        if (tm.ggg(cpp11_ref_qualifiers_typemaps.GG7_MFP).toInt() != 9)
            throw RuntimeException("failed")
        if (tm.hhh(cpp11_ref_qualifiers_typemaps.HH10_MFP).toInt() != 12)
            throw RuntimeException("failed")
    }
}

@file:JvmName("member_pointer_const_runme")

import member_pointer_const.*

fun check(what: String, expected: Double, actual: Double) {
    if (expected != actual)
        throw RuntimeException("Failed: " + what + " Expected: " + expected + " Actual: " + actual)
}

fun main() {
    try {
        System.loadLibrary("member_pointer_const")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    var memberPtr: SWIGTYPE_m_Shape__f_void__double? = null

    // Get the pointers
    val area_pt = member_pointer_const.areapt()
    val perim_pt = member_pointer_const.perimeterpt()

    // Create some objects
    val s = Square(10.0)

    // Do some calculations
    check("Square area ", 100.0, member_pointer_const.do_op(s, area_pt))
    check("Square perim", 40.0, member_pointer_const.do_op(s, perim_pt))

    memberPtr = member_pointer_const.areavar
    memberPtr = member_pointer_const.perimetervar

    // Try the variables
    check("Square area ", 100.0, member_pointer_const.do_op(s, member_pointer_const.areavar))
    check("Square perim", 40.0, member_pointer_const.do_op(s, member_pointer_const.perimetervar))

    // Modify one of the variables
    member_pointer_const.areavar = perim_pt

    check("Square perimeter", 40.0, member_pointer_const.do_op(s, member_pointer_const.areavar))

    // Try the constants
    memberPtr = member_pointer_const.AREAPT
    memberPtr = member_pointer_const.PERIMPT
    memberPtr = member_pointer_const.NULLPT

    check("Square area ", 100.0, member_pointer_const.do_op(s, member_pointer_const.AREAPT))
    check("Square perim", 40.0, member_pointer_const.do_op(s, member_pointer_const.PERIMPT))

    // Typedefs
    check("Square perim", 40.0, member_pointer_const.do_op_td(s, perim_pt))
}

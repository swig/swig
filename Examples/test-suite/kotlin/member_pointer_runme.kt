@file:JvmName("member_pointer_runme")

import member_pointer.*

fun check(what: String, expected: Double, actual: Double) {
    if (expected != actual)
        throw RuntimeException("Failed: " + what + " Expected: " + expected + " Actual: " + actual)
}

fun main() {
    try {
        System.loadLibrary("member_pointer")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    var memberPtr: SWIGTYPE_m_Shape__f_void__double? = null

    // Get the pointers
    val area_pt = member_pointer.areapt()
    val perim_pt = member_pointer.perimeterpt()

    // Create some objects
    val s = Square(10.0)

    // Do some calculations
    check("Square area ", 100.0, member_pointer.do_op(s, area_pt))
    check("Square perim", 40.0, member_pointer.do_op(s, perim_pt))

    memberPtr = member_pointer.areavar
    memberPtr = member_pointer.perimetervar

    // Try the variables
    check("Square area ", 100.0, member_pointer.do_op(s, member_pointer.areavar))
    check("Square perim", 40.0, member_pointer.do_op(s, member_pointer.perimetervar))

    // Modify one of the variables
    member_pointer.areavar = perim_pt

    check("Square perimeter", 40.0, member_pointer.do_op(s, member_pointer.areavar))

    // Try the constants
    memberPtr = member_pointer.AREAPT
    memberPtr = member_pointer.PERIMPT
    memberPtr = member_pointer.NULLPT

    check("Square area ", 100.0, member_pointer.do_op(s, member_pointer.AREAPT))
    check("Square perim", 40.0, member_pointer.do_op(s, member_pointer.PERIMPT))

    // Typedefs
    check("Square perim", 40.0, member_pointer.do_op_td(s, perim_pt))
}

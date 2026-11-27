@file:JvmName("member_pointer_runme")

import member_pointer.*

fun check(what: String, expected: Double, actual: Double) {
    if (expected != actual)
        throw RuntimeException("Failed: " + what + " Expected: " + expected + " Actual: " + actual)
}
fun check(what: String, expected: Int, actual: Int) {
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

    @Suppress("ASSIGNED_BUT_NEVER_ACCESSED_VARIABLE")
    var memberPtr: SWIGTYPE_m_Shape__f_void__double? = null

    // Get the pointers
    val area_pt = member_pointer.areapt()
    val perim_pt = member_pointer.perimeterpt()

    // Create some objects
    val s = Square(10.0)

    // Do some calculations
    check("Square area ", 100.0, member_pointer.do_op(s, area_pt))
    check("Square perim", 40.0, member_pointer.do_op(s, perim_pt))

    @Suppress("UNUSED_VALUE")
    memberPtr = member_pointer.areavar
    @Suppress("UNUSED_VALUE")
    memberPtr = member_pointer.perimetervar

    // Try the variables
    check("Square area ", 100.0, member_pointer.do_op(s, member_pointer.areavar))
    check("Square perim", 40.0, member_pointer.do_op(s, member_pointer.perimetervar))

    // Modify one of the variables
    member_pointer.areavar = perim_pt

    check("Square perimeter", 40.0, member_pointer.do_op(s, member_pointer.areavar))

    // Try the constants
    @Suppress("UNUSED_VALUE")
    memberPtr = member_pointer.AREAPT
    @Suppress("UNUSED_VALUE")
    memberPtr = member_pointer.PERIMPT
    @Suppress("UNUSED_VALUE")
    memberPtr = member_pointer.NULLPT

    check("Square area ", 100.0, member_pointer.do_op(s, member_pointer.AREAPT))
    check("Square perim", 40.0, member_pointer.do_op(s, member_pointer.PERIMPT))

    // Typedefs
    check("Square perim", 40.0, member_pointer.do_op_td(s, perim_pt))

    // Const references to member pointers
    if (area_pt != null)
      check("Square area", 100.0, member_pointer.do_op_cref(s, area_pt));
    check("Square perim", 40.0, member_pointer.do_op_cref(s,member_pointer.perimetervar_td_cref()));
    check("Square perim", 40.0, member_pointer.do_op(s,member_pointer.perimetervar_td_cref()));

    // Overloaded on the member pointer type
    check("Overload by value", 3, member_pointer.call_overloaded(member_pointer.ADD_BY_VALUE, 1, 2));
    check("Overload by pointer", -7, member_pointer.call_overloaded(member_pointer.ADD_BY_POINTER, 3, 4));
    check("Overload by int", 110, member_pointer.call_overloaded(10, 5, 6));

    // NULL member pointers
    if (member_pointer.get_null_memberpt() != null)
      throw RuntimeException("get_null_memberpt() is not null");
    if (!member_pointer.is_null_memberpt(null))
      throw RuntimeException("is_null_memberpt(null) failed");
    if (!member_pointer.is_null_memberpt(member_pointer.NULLPT))
      throw RuntimeException("is_null_memberpt(NULLPT) failed");
    if (member_pointer.is_null_memberpt(area_pt))
      throw RuntimeException("is_null_memberpt(area_pt) failed");
    member_pointer.areavar = null;
    if (member_pointer.areavar != null)
      throw RuntimeException("areavar is not null");
    if (area_pt != null && member_pointer.is_null_memberpt_cref(area_pt))
      throw RuntimeException("is_null_memberpt_cref(area_pt) failed");
}

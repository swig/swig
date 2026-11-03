import member_pointer.*;

public class member_pointer_runme {

  static {
    try {
        System.loadLibrary("member_pointer");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static SWIGTYPE_m_Shape__f_void__double memberPtr = null;

  public static void main(String argv[]) {
    // Get the pointers

    SWIGTYPE_m_Shape__f_void__double area_pt = member_pointer.areapt();
    SWIGTYPE_m_Shape__f_void__double perim_pt = member_pointer.perimeterpt();

    // Create some objects

    Square s = new Square(10);

    // Do some calculations

    check( "Square area ", 100.0, member_pointer.do_op(s,area_pt) );
    check( "Square perim", 40.0, member_pointer.do_op(s,perim_pt) );

    memberPtr = member_pointer.getAreavar();
    memberPtr = member_pointer.getPerimetervar();

    // Try the variables
    check( "Square area ", 100.0, member_pointer.do_op(s,member_pointer.getAreavar()) );
    check( "Square perim", 40.0, member_pointer.do_op(s,member_pointer.getPerimetervar()) );

    // Modify one of the variables
    member_pointer.setAreavar(perim_pt);

    check( "Square perimeter", 40.0, member_pointer.do_op(s,member_pointer.getAreavar()) );

    // Try the constants

    memberPtr = member_pointer.AREAPT;
    memberPtr = member_pointer.PERIMPT;
    memberPtr = member_pointer.NULLPT;

    check( "Square area ", 100.0, member_pointer.do_op(s,member_pointer.AREAPT) );
    check( "Square perim", 40.0, member_pointer.do_op(s,member_pointer.PERIMPT) );

    // Typedefs
    check( "Square perim", 40.0, member_pointer.do_op_td(s,perim_pt) );

    // Const references to member pointers
    check( "Square area", 100.0, member_pointer.do_op_cref(s,area_pt) );
    check( "Square perim", 40.0, member_pointer.do_op_cref(s,member_pointer.perimetervar_td_cref()) );
    check( "Square perim", 40.0, member_pointer.do_op(s,member_pointer.perimetervar_td_cref()) );

    // Overloaded on the member pointer type
    check( "Overload by value", 3, member_pointer.call_overloaded(member_pointer.ADD_BY_VALUE, 1, 2) );
    check( "Overload by pointer", -7, member_pointer.call_overloaded(member_pointer.ADD_BY_POINTER, 3, 4) );
    check( "Overload by int", 110, member_pointer.call_overloaded(10, 5, 6) );

    // NULL member pointers
    if (member_pointer.get_null_memberpt() != null)
      throw new RuntimeException("get_null_memberpt() is not null");
    if (!member_pointer.is_null_memberpt(null))
      throw new RuntimeException("is_null_memberpt(null) failed");
    if (!member_pointer.is_null_memberpt(member_pointer.NULLPT))
      throw new RuntimeException("is_null_memberpt(NULLPT) failed");
    if (member_pointer.is_null_memberpt(area_pt))
      throw new RuntimeException("is_null_memberpt(area_pt) failed");
    member_pointer.setAreavar(null);
    if (member_pointer.getAreavar() != null)
      throw new RuntimeException("areavar is not null");
    if (member_pointer.get_null_memberpt_cref() != null)
      throw new RuntimeException("get_null_memberpt_cref() is not null");
    if (!member_pointer.is_null_memberpt_cref(null))
      throw new RuntimeException("is_null_memberpt_cref(null) failed");
    if (member_pointer.is_null_memberpt_cref(area_pt))
      throw new RuntimeException("is_null_memberpt_cref(area_pt) failed");
  }

  private static void check(String what, double expected, double actual) {
    if (expected != actual)
      throw new RuntimeException("Failed: " + what + " Expected: " + expected + " Actual: " + actual);
  }
}

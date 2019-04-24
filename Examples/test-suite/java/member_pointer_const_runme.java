import member_pointer_const.*;

public class member_pointer_const_runme {

  static {
    try {
        System.loadLibrary("member_pointer_const");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static SWIGTYPE_m_Shape__f_void__double memberPtr = null;

  public static void main(String argv[]) {
    // Get the pointers

    SWIGTYPE_m_Shape__f_void__double area_pt = member_pointer_const.areapt();
    SWIGTYPE_m_Shape__f_void__double perim_pt = member_pointer_const.perimeterpt();

    // Create some objects

    Square s = new Square(10);

    // Do some calculations

    check( "Square area ", 100.0, member_pointer_const.do_op(s,area_pt) );
    check( "Square perim", 40.0, member_pointer_const.do_op(s,perim_pt) );

    memberPtr = member_pointer_const.getAreavar();
    memberPtr = member_pointer_const.getPerimetervar();

    // Try the variables
    check( "Square area ", 100.0, member_pointer_const.do_op(s,member_pointer_const.getAreavar()) );
    check( "Square perim", 40.0, member_pointer_const.do_op(s,member_pointer_const.getPerimetervar()) );

    // Modify one of the variables
    member_pointer_const.setAreavar(perim_pt);

    check( "Square perimeter", 40.0, member_pointer_const.do_op(s,member_pointer_const.getAreavar()) );

    // Try the constants

    memberPtr = member_pointer_const.AREAPT;
    memberPtr = member_pointer_const.PERIMPT;
    memberPtr = member_pointer_const.NULLPT;

    check( "Square area ", 100.0, member_pointer_const.do_op(s,member_pointer_const.AREAPT) );
    check( "Square perim", 40.0, member_pointer_const.do_op(s,member_pointer_const.PERIMPT) );

    // Typedefs
    check( "Square perim", 40.0, member_pointer_const.do_op_td(s,perim_pt) );
  }

  private static void check(String what, double expected, double actual) {
    if (expected != actual)
      throw new RuntimeException("Failed: " + what + " Expected: " + expected + " Actual: " + actual);
  }
}

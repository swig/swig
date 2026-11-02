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

  public static SWIGTYPE_m_Shape__q_const__f_void__double memberPtr = null;

  public static void main(String argv[]) {
    // Get the pointers

    SWIGTYPE_m_Shape__q_const__f_void__double area_pt = member_pointer_const.areapt();
    SWIGTYPE_m_Shape__q_const__f_void__double perim_pt = member_pointer_const.perimeterpt();

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

    // The declarators after the first in a list
    check( "Square perim", 40.0, member_pointer_const.do_op_list_td(s,perim_pt) );
    check( "Square perim", 40.0, member_pointer_const.do_op(s,member_pointer_const.perimeterptlist()) );
    check( "Square perim", 40.0, member_pointer_const.do_op(s,member_pointer_const.getPerimetervarlist()) );
    check( "Square perim", 40.0, member_pointer_const.do_op(s,new MemberPointerGetter().getPerimeterPtList()) );

    // Member functions returning member pointers
    MemberPointerGetter getter = new MemberPointerGetter();
    check( "Square area ", 100.0, member_pointer_const.do_op(s,getter.getAreaPt()) );
    check( "Square area ", 100.0, member_pointer_const.do_op(s,getter.getConstAreaPt()) );
    check( "Square area ", 100.0, member_pointer_const.do_op(s,MemberPointerGetter.getStaticAreaPt()) );

    // Member pointers to a namespaced class
    Adder adder = new Adder();
    check( "Add by member pointer", 11, adder.callAddPt(adder.getAddPt(), 10) );
    if (!member_pointer_const.getAddPtDeclaration().equals("int (MemberPointerSpace::Adder::*MemberPointerSpace::Adder::getAddPt())(int) const"))
      throw new RuntimeException("Incorrect declaration: " + member_pointer_const.getAddPtDeclaration());
  }

  private static void check(String what, double expected, double actual) {
    if (expected != actual)
      throw new RuntimeException("Failed: " + what + " Expected: " + expected + " Actual: " + actual);
  }
}

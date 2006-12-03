// Example using pointers to member functions

public class main {
  static {
    try {
        System.loadLibrary("example");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) 
  {
      // Get the pointers

      SWIGTYPE_m_Shape__f_void__double area_pt = example.areapt();
      SWIGTYPE_m_Shape__f_void__double perim_pt = example.perimeterpt();

      System.out.println( "area_pt  =" + area_pt );
      System.out.println( "perim_pt = " + perim_pt );

      // Create some objects

      Circle c = new Circle(4);
      Square s = new Square(10);

      // Do some calculations

      System.out.println( "Circle area  = " + example.do_op(c,area_pt) );
      System.out.println( "Circle perim = " + example.do_op(c,perim_pt) );
      System.out.println( "Square area  = " + example.do_op(s,area_pt) );
      System.out.println( "Square perim = " + example.do_op(s,perim_pt) );

      System.out.println( "areavar      = " + example.getAreavar() );
      System.out.println( "perimetervar = " + example.getPerimetervar() );

      // Try the variables
      System.out.println( "Circle area  = " + example.do_op(c,example.getAreavar()) );
      System.out.println( "Circle perim = " + example.do_op(c,example.getPerimetervar()) );
      System.out.println( "Square area  = " + example.do_op(s,example.getAreavar()) );
      System.out.println( "Square perim = " + example.do_op(s,example.getPerimetervar()) );

      // Modify one of the variables
      example.setAreavar(perim_pt);

      System.out.println( "Circle perimeter = " + example.do_op(c,example.getAreavar()) );

      // Try the constants

      System.out.println( "example.AREAPT =" + example.AREAPT );
      System.out.println( "example.PERIMPT=" + example.PERIMPT );
      System.out.println( "example.NULLPT =" + example.NULLPT );

      System.out.println( "Circle area  = " + example.do_op(c,example.AREAPT) );
      System.out.println( "Circle perim = " + example.do_op(c,example.PERIMPT) );
      System.out.println( "Square area  = " + example.do_op(s,example.AREAPT) );
      System.out.println( "Square perim = " + example.do_op(s,example.PERIMPT) );

  }
}

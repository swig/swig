
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
    // Print out the value of some enums
    System.out.println("*** color ***");
    System.out.println("    RED    = " + example.RED);
    System.out.println("    BLUE   = " + example.BLUE);
    System.out.println("    GREEN  = " + example.GREEN);

    System.out.println("\n*** Foo::speed ***");
    System.out.println("    Foo::IMPULSE   = " + Foo.IMPULSE);
    System.out.println("    Foo::WARP      = " + Foo.WARP);
    System.out.println("    Foo::LUDICROUS = " + Foo.LUDICROUS);

    System.out.println("\nTesting use of enums with functions\n");

    example.enum_test(example.RED, Foo.IMPULSE);
    example.enum_test(example.BLUE, Foo.WARP);
    example.enum_test(example.GREEN, Foo.LUDICROUS);
    example.enum_test(1234,5678);

    System.out.println( "\nTesting use of enum with class method" );
    Foo f = new Foo();

    f.enum_test(Foo.IMPULSE);
    f.enum_test(Foo.WARP);
    f.enum_test(Foo.LUDICROUS);
  }
}

import template_advanced_rename.*;

public class template_advanced_rename_runme {

  static {
    try {
	System.loadLibrary("template_advanced_rename");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    template_advanced_rename.funky_int(10, 20);
    template_advanced_rename.funky_int(30);
    template_advanced_rename.funky_void();

    template_advanced_rename.funky_double(10.1, 20.2);
    template_advanced_rename.funky_double(30.3) ;
    template_advanced_rename.Funky_NoParms();

    template_advanced_rename.FUNKY(true, false);
    template_advanced_rename.FUNKY(true);
    template_advanced_rename.FUNKY();

    template_advanced_rename.Goose(40);
    template_advanced_rename.Golden_goose(true);

    if (new Wonky_Renamed().twiddle(5) != 5)
      throw new RuntimeException("Wonky_Renamed failed");
    if (new WONKY().twiddle(5.5) != 5.5)
      throw new RuntimeException("WONKY failed");
    if (new Quirky_Wonky().twiddle(true) != true)
      throw new RuntimeException("Quirky_Wonky failed");

    if (new BumpyInt().flat(5) != 5)
      throw new RuntimeException("BumpyInt failed");
    if (new BumpyBool().boolish(true) != true)
      throw new RuntimeException("BumpyBool failed");
    if (new BumpyPtr() == null)
      throw new RuntimeException("BumpyPtr failed");

    check(1, template_advanced_rename.spinner(10));
    check(2, template_advanced_rename.spinner(10, 20));
  }

  static void check(int expected, int actual) {
    if (expected != actual)
      throw new RuntimeException("expected " + expected + " but got " + actual);
  }
}

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
  }
}

import cpp20_abbreviated_template_directives.*;

public class cpp20_abbreviated_template_directives_runme {

  static {
    try {
      System.loadLibrary("cpp20_abbreviated_template_directives");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void checkLastCalled(String expected) {
    String got = cpp20_abbreviated_template_directives.getLastCalled();
    if (!got.equals(expected))
      throw new RuntimeException("expected: " + expected + " got: " + got);
  }

  public static void main(String argv[]) {
    cpp20_abbreviated_template_directives.fell_int(8);
    checkLastCalled("fell[int]: void fell< int >(int)");
    cpp20_abbreviated_template_directives.fell_string("down");
    checkLastCalled("fell[string]: void fell< std::string >(std::string)");
    cpp20_abbreviated_template_directives.fell_bool(true);
    checkLastCalled("fell: void fell< bool >(bool)");

    cpp20_abbreviated_template_directives.climbed_int(7);
    checkLastCalled("climbed[int]: void climbed< int >(int)");
    cpp20_abbreviated_template_directives.climbed_string("up");
    checkLastCalled("climbed[string]: void climbed< std::string >(std::string)");
    cpp20_abbreviated_template_directives.climbed_bool(true);
    checkLastCalled("climbed: void climbed< bool >(bool)");

    if (cpp20_abbreviated_template_directives.picked_renamed(2.5) != 4)
      throw new RuntimeException("picked_renamed(2.5)");
    if (cpp20_abbreviated_template_directives.picked_short((short)3) != 6)
      throw new RuntimeException("picked_short(3)");

    if (cpp20_abbreviated_template_directives.bumped_one(1) != 2)
      throw new RuntimeException("bumped_one(1)");
    if (cpp20_abbreviated_template_directives.bumped_all(1, 5) != 6)
      throw new RuntimeException("bumped_all(1, 5)");

    if (cpp20_abbreviated_template_directives.pack_then_one_renamed(1, 2, 3.5) != 6)
      throw new RuntimeException("pack_then_one_renamed(1, 2, 3.5)");

    if (!cpp20_abbreviated_template_directives.specialized_const_int(1).equals("const int"))
      throw new RuntimeException("specialized_const_int(1)");
  }
}

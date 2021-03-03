import cpp11_raw_string_literals.*;

public class cpp11_raw_string_literals_runme {

  static {
    try {
	System.loadLibrary("cpp11_raw_string_literals");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    if (cpp11_raw_string_literals.getL() != 100)
      throw new RuntimeException("failed!");

    if (cpp11_raw_string_literals.getU8() != 100)
      throw new RuntimeException("failed!");

    if (cpp11_raw_string_literals.getU() != 100)
      throw new RuntimeException("failed!");

    if (UStruct.U != 100)
      throw new RuntimeException("failed!");


    if (cpp11_raw_string_literals.getR() != 100)
      throw new RuntimeException("failed!");

    if (cpp11_raw_string_literals.getLR() != 100)
      throw new RuntimeException("failed!");

    if (cpp11_raw_string_literals.getU8R() != 100)
      throw new RuntimeException("failed!");

    if (cpp11_raw_string_literals.getUR() != 100)
      throw new RuntimeException("failed!");

    if (URStruct.UR != 100)
      throw new RuntimeException("failed!");


    if (!cpp11_raw_string_literals.getAa().equals("Wide string"))
      throw new RuntimeException("failed!");

    if (!cpp11_raw_string_literals.getBb().equals("UTF-8 string"))
      throw new RuntimeException("failed!");

    if (!cpp11_raw_string_literals.getXx().equals(")I'm an \"ascii\" \\ string."))
      throw new RuntimeException("failed!");

    if (!cpp11_raw_string_literals.getEe().equals(")I'm an \"ascii\" \\ string."))
      throw new RuntimeException("failed!");

    if (!cpp11_raw_string_literals.getFf().equals("I'm a \"raw wide\" \\ string."))
      throw new RuntimeException("failed!");

    if (!cpp11_raw_string_literals.getGg().equals("I'm a \"raw UTF-8\" \\ string."))
      throw new RuntimeException("failed!");



    if (!cpp11_raw_string_literalsConstants.mm.equals(")I'm an \"ascii\" \\ string constant with multiple\n\nlines."))
      throw new RuntimeException("failed!");
  }
}

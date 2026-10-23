import string_constants.*;

public class string_constants_runme {
  static {
    try {
      System.loadLibrary("string_constants");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[])
  {
    if (!string_constants.ES1.equals(""))
      throw new RuntimeException("fail");
    if (!string_constants.ES2.equals(""))
      throw new RuntimeException("fail");
    if (!string_constants.ZS1.equals("\000"))
      throw new RuntimeException("fail");
    if (!string_constants.ZS2.equals("\000"))
      throw new RuntimeException("fail");
    for (String s : new String[] { string_constants.EN1, string_constants.EN2, things.EN5 })
      if (!s.equals("a\000bc"))
        throw new RuntimeException("fail: " + s);
    for (String s : new String[] { string_constants.SS1, string_constants.SS2, string_constants.UU1, string_constants.UU2, things.SS5 })
      if (!s.equals("\u00C6\u00CEOU\n"))
        throw new RuntimeException("fail: " + s);
    if (string_constants.WS1 == null || string_constants.WC1 == null || string_constants.WS2 == null || things.WS5 == null)
      throw new RuntimeException("fail");
    if (!string_constants.OL1.equals("\300\242"))
      throw new RuntimeException("fail: " + string_constants.OL1);
    if (!string_constants.WS6.equals("\u00C6\"\uD83D\uDE00\u00E97"))
      throw new RuntimeException("fail: " + string_constants.WS6);
    if (string_constants.WC6 != '\u00C6')
      throw new RuntimeException("fail: " + string_constants.WC6);
  }
}


import cpp11_noexcept.*;

public class cpp11_noexcept_runme {

  static {
    try {
      System.loadLibrary("cpp11_noexcept");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // A pointer to a noexcept function converts to a pointer to the function without noexcept
    if (cpp11_noexcept.noexceptCallIntFunc(cpp11_noexcept.noexceptGetAddTwo(), 1) != 3)
      throw new RuntimeException("noexceptCallIntFunc failed");
    if (cpp11_noexcept.noexceptCallNoExceptFunc(cpp11_noexcept.noexceptGetAddTwo(), 2) != 4)
      throw new RuntimeException("noexceptCallNoExceptFunc failed");
  }
}


import cpp11_directors.*;

public class cpp11_directors_runme {

  static {
    try {
      System.loadLibrary("cpp11_directors");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // The exception reaches the caller of ping(), which is not noexcept in the director class
    try {
      NoExceptFalse.callPing(new cpp11_directors_MyNoExceptFalse());
      throw new RuntimeException("Failed to catch exception");
    } catch (UnsupportedOperationException e) {
      if (!e.getMessage().equals("MyNoExceptFalse.ping"))
        throw new RuntimeException("Unexpected exception message: " + e.getMessage());
    }
  }
}

class cpp11_directors_MyNoExceptFalse extends NoExceptFalse {
  @Override
  public int ping() {
    throw new UnsupportedOperationException("MyNoExceptFalse.ping");
  }
}

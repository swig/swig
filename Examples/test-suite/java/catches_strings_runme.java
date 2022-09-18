import catches_strings.*;

public class catches_strings_runme {
  static {
    try {
        System.loadLibrary("catches_strings");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) throws Throwable
  {
    {
      boolean exception_thrown = false;
      try {
        StringsThrower.charstring();
      } catch (RuntimeException e) {
        if (!e.getMessage().contains("charstring message"))
          throw new RuntimeException("incorrect exception message");
        exception_thrown = true;
      }
      if (!exception_thrown)
        throw new RuntimeException("Should have thrown an exception");
    }

    {
      boolean exception_thrown = false;
      try {
        StringsThrower.stdstring();
      } catch (RuntimeException e) {
        if (!e.getMessage().contains("stdstring message"))
          throw new RuntimeException("incorrect exception message");
        exception_thrown = true;
      }
      if (!exception_thrown)
        throw new RuntimeException("Should have thrown an exception");
    }
  }
}

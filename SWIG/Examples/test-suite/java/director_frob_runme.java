
import director_frob.*;
import java.lang.reflect.*;

public class director_frob_runme
{
  static {
    try {
      System.loadLibrary("director_frob");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String args[])
  {
    Bravo foo = new Bravo();

    String s = foo.abs_method();
    if (!s.equals("Bravo::abs_method()"))
        throw new RuntimeException( "error" );
  }
}
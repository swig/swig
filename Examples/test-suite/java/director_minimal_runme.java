import director_minimal.*;

public class director_minimal_runme {

  static {
    try {
        System.loadLibrary("director_minimal");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) throws Throwable
  {
    MyMinimal c = new MyMinimal();
    if (!c.get())
       throw new Exception("Should return true");
  }
}

class MyMinimal extends Minimal
{
  public boolean run()
  {
    return true;
  }
}

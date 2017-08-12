
import namespace_chase.*;

public class namespace_chase_runme {

  static {
    try {
      System.loadLibrary("namespace_chase");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) 
  {
    Struct1A s1a = new Struct1A();
    Struct1B s1b = new Struct1B();
    Struct1C s1c = new Struct1C();

    namespace_chase.sss3a(s1a, s1b, s1c);
    namespace_chase.sss3b(s1a, s1b, s1c);
    // needs fixing
//    namespace_chase.sss3c(s1a, s1b, s1c);
  }
}


import director_string.*;

public class director_string_runme {

  static {
    try {
      System.loadLibrary("director_string");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    B b = new B("hello");

    String s;

    s = b.call_get_first();
    if (!s.equals("B.get_first")) throw new RuntimeException("call_get_first() failed");

    s = b.call_get(0);
    if (!s.equals("B.get: hello")) throw new RuntimeException("get(0) failed");
  }
}

class B extends A {
    public B(String first) {
      super(first);
    }
    public String get_first() {
      return "B.get_first";
    }
  
    public String get(int n) {
      return "B.get: " + super.get(n);
    }
}


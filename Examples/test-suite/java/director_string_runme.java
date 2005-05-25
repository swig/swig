
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

    director_string_B b = new director_string_B("hello");

    String s;

    s = b.call_get_first();
    if (!s.equals("director_string_B.get_first")) throw new RuntimeException("call_get_first() failed");

    s = b.call_get(0);
    if (!s.equals("director_string_B.get")) throw new RuntimeException("get(0) failed");
//    if (!s.equals("director_string_B.get: hello")) throw new RuntimeException("get(0) failed");
  }
}

class director_string_B extends A {
    public director_string_B(String first) {
      super(first);
    }
    public String get_first() {
      return "director_string_B.get_first";
    }
  
    public String get(int n) {
      return "director_string_B.get";
// recursive call problem (needs fixing)
//      return "director_string_B.get: " + super.get(n);
    }
}


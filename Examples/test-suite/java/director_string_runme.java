
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

    b.get(0);
    b.get_first();
  }
}

class B extends A {
    public B(String first) {
      super(first);
    }
    public String get_first() {
      return get(0);
    }
  
    public String get(int n) {
      return super.get(n);
    }
}


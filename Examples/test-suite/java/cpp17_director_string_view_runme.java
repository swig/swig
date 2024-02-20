
import cpp17_director_string_view.*;

public class cpp17_director_string_view_runme {

  static {
    try {
      System.loadLibrary("cpp17_director_string_view");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    String s;

    cpp17_director_string_view_A c = new cpp17_director_string_view_A("hi");
    for (int i=0; i<3; i++) {
      s = c.call_get(i);
      if (!s.equals(Integer.valueOf(i).toString())) throw new RuntimeException("cpp17_director_string_view_A.get(" + i + ") failed. Got:" + s);
    }

    cpp17_director_string_view_B b = new cpp17_director_string_view_B("hello");

    s = b.get_first();
    if (!s.equals("cpp17_director_string_view_B.get_first")) throw new RuntimeException("get_first() failed");

    s = b.call_get_first();
    if (!s.equals("cpp17_director_string_view_B.get_first")) throw new RuntimeException("call_get_first() failed");

    s = b.call_get(0);
    if (!s.equals("cpp17_director_string_view_B.get: hello")) throw new RuntimeException("get(0) failed");
  }
}

class cpp17_director_string_view_B extends A {
    public cpp17_director_string_view_B(String first) {
      super(first);
    }
    public String get_first() {
      return "cpp17_director_string_view_B.get_first";
    }

    public String get(int n) {
      return "cpp17_director_string_view_B.get: " + super.get(n);
    }
}

class cpp17_director_string_view_A extends A {
    public cpp17_director_string_view_A(String first) {
      super(first);
    }
    public String get(int n) {
      return Integer.valueOf(n).toString();
    }
}


import director_char_array.*;

public class director_char_array_runme {

  static {
    try {
      System.loadLibrary("director_char_array");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  static void check(int got, int expected, String what) {
    if (got != expected)
      throw new RuntimeException(what + " got " + got + " expected " + expected);
  }

  public static void main(String argv[]) {
    Director d = new Director();
    check(d.call_take_array(), 4, "take_array");
    check(d.call_take_const_array(), 4, "take_const_array");
    check(d.call_take_array_ref(), 4, "take_array_ref");
    check(d.call_take_const_array_ref(), 4, "take_const_array_ref");
    check(d.call_take_array_short(), 2, "take_array short");
    check(d.call_take_array_ref_short(), 2, "take_array_ref short");
    check(d.call_is_null_array(), 1, "is_null_array");
  }
}

class Director extends CharArrayDirector {
  @Override
  public int take_array(String s) { return s.length(); }
  @Override
  public int take_const_array(String s) { return s.length(); }
  @Override
  public int take_array_ref(String s) { return s.length(); }
  @Override
  public int take_const_array_ref(String s) { return s.length(); }
  @Override
  public int is_null_array(String s) { return s == null ? 1 : 0; }
}

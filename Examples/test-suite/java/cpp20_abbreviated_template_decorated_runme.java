import cpp20_abbreviated_template_decorated.*;

public class cpp20_abbreviated_template_decorated_runme {

  static {
    try {
      System.loadLibrary("cpp20_abbreviated_template_decorated");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // Decorated parms h (auto&), i (auto*), j (auto&&), m (Numeric auto&) wrap as SWIG pointer
    // parms in Java by default and aren't directly callable with a Java int.  Verify the wrappers
    // were generated.
    try {
      cpp20_abbreviated_template_decorated.class.getMethod("h_dec_i", SWIGTYPE_p_int.class);
      cpp20_abbreviated_template_decorated.class.getMethod("i_dec_i", SWIGTYPE_p_int.class);
      cpp20_abbreviated_template_decorated.class.getMethod("j_dec_i", SWIGTYPE_p_int.class);
      cpp20_abbreviated_template_decorated.class.getMethod("m_dec_i", SWIGTYPE_p_int.class);
    } catch (NoSuchMethodException e) {
      throw new RuntimeException("missing decorated auto wrapper: " + e.getMessage());
    }

    // k. const auto (by value)
    if (cpp20_abbreviated_template_decorated.k_dec_i(13) != 13)
      throw new RuntimeException("k_dec_i");

    // l. const auto& (const ref to int wraps as pass by value for Java)
    if (cpp20_abbreviated_template_decorated.l_dec_i(14) != 14)
      throw new RuntimeException("l_dec_i");

    // n. const Numeric auto&
    if (cpp20_abbreviated_template_decorated.n_dec_i(16) != 16)
      throw new RuntimeException("n_dec_i");

    // o. Decorated auto mixed with explicit head.  T=std::string, auto=int.
    if (!cpp20_abbreviated_template_decorated.o_dec_si("box", 9).equals("box:9"))
      throw new RuntimeException("o_dec_si");
  }
}

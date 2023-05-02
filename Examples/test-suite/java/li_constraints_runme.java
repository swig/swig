
import java.util.function.*;
import li_constraints.*;

public class li_constraints_runme {

  static {
    try {
	System.loadLibrary("li_constraints");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void check_double(boolean except, Consumer<Double> f, double val, String ex) {
      boolean actual = true;
      boolean proper = false;
      try {
        f.accept(val);
      } catch(RuntimeException e) {
        actual = false;
        proper = e.getMessage().equals(String.join(" ", "Expected", "a", ex, "value."));
      }
      if (actual) {
        if (!except) {
          throw new RuntimeException(String.join("", "function '", ex, "' with ", String.valueOf(val), " should perform an exception"));
        }
      } else {
        if (except) {
          throw new RuntimeException(String.join("", "function '", ex, "' with ", String.valueOf(val), " should not perform an exception"));
        } else if (!proper) {
          throw new RuntimeException(String.join("", "function '", ex, "' with ", String.valueOf(val), " should perform a proper exception"));
        }
      }
  }

  public static void main(String argv[]) {

      Consumer<Double> func = v -> li_constraints.test_nonnegative(v);
      check_double(true, func, 10, "non-negative");
      check_double(true, func, 0, "non-negative");
      check_double(false, func, -10, "non-negative");

      func = v -> li_constraints.test_nonpositive(v);
      check_double(false, func, 10, "non-positive");
      check_double(true, func, 0, "non-positive");
      check_double(true, func, -10, "non-positive");

      func = v -> li_constraints.test_positive(v);
      check_double(true, func, 10, "positive");
      check_double(false, func, 0, "positive");
      check_double(false, func, -10, "positive");

      func = v -> li_constraints.test_negative(v);
      check_double(false, func, 10, "negative");
      check_double(false, func, 0, "negative");
      check_double(true, func, -10, "negative");

      func = v -> li_constraints.test_nonzero(v);
      check_double(true, func, 10, "nonzero");
      check_double(false, func, 0, "nonzero");
      check_double(true, func, -10, "nonzero");

      boolean have_exception = false;
      try {
        li_constraints.test_nonnull(null);
      } catch(Exception e) {
        have_exception = e.getMessage().equals("Received a NULL pointer.");
      }
      if (!have_exception) {
          throw new RuntimeException("test_nonnull should perform proper exception with 'null' value");
      }
      SWIGTYPE_p_void nonnull = li_constraints.get_nonnull();
      li_constraints.test_nonnull(nonnull);
  }
}

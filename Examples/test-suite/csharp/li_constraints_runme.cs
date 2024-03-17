using System;
using li_constraintsNamespace;

public class runme {
    static void check_double(bool except, Action<double> f, double val, string ex) {
      bool actual = true;
      bool proper = false;
      try {
        f(val);
      } catch(Exception e) {
        actual = false;
        proper = e.Message.Equals(string.Join(" ", "Expected", "a", ex, "value."));
      }
      if (actual) {
        if (!except)
          throw new Exception(string.Join("", "function '", ex, "' with ", val.ToString(), " should perform an exception"));
      } else {
        if (except)
          throw new Exception(string.Join("", "function '", ex, "' with ", val.ToString(), " should not perform an exception"));
        else if (!proper)
          throw new Exception(string.Join("", "function '", ex, "' with ", val.ToString(), " should perform a proper exception"));
      }
    }

    static void Main() {
      check_double(true, li_constraints.test_nonnegative, 10, "non-negative");
      check_double(true, li_constraints.test_nonnegative, 0, "non-negative");
      check_double(false, li_constraints.test_nonnegative, -10, "non-negative");

      check_double(false, li_constraints.test_nonpositive, 10, "non-positive");
      check_double(true, li_constraints.test_nonpositive, 0, "non-positive");
      check_double(true, li_constraints.test_nonpositive, -10, "non-positive");

      check_double(true, li_constraints.test_positive, 10, "positive");
      check_double(false, li_constraints.test_positive, 0, "positive");
      check_double(false, li_constraints.test_positive, -10, "positive");

      check_double(false, li_constraints.test_negative, 10, "negative");
      check_double(false, li_constraints.test_negative, 0, "negative");
      check_double(true, li_constraints.test_negative, -10, "negative");

      check_double(true, li_constraints.test_nonzero, 10, "nonzero");
      check_double(false, li_constraints.test_nonzero, 0, "nonzero");
      check_double(true, li_constraints.test_nonzero, -10, "nonzero");

      bool have_exception = false;
      try {
        li_constraints.test_nonnull(null);
      } catch(Exception e) {
        have_exception = e.Message.Equals("Received a NULL pointer.");
      }
      if (!have_exception)
          throw new Exception("test_nonnull should perform proper exception with 'null' value");
      SWIGTYPE_p_void nonnull = li_constraints.get_nonnull();
      li_constraints.test_nonnull(nonnull);
    }
}

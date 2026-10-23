import cpp20_concepts_lambda.*;

public class cpp20_concepts_lambda_runme {

  static {
    try {
      System.loadLibrary("cpp20_concepts_lambda");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // Trailing requires-clause - bare concept.
    if (cpp20_concepts_lambda.run_trailing(5) != 10)
      throw new RuntimeException("run_trailing(5)");

    // Trailing requires-clause - compound '&&'.
    if (cpp20_concepts_lambda.run_compound(7) != 14)
      throw new RuntimeException("run_compound(7)");

    // Trailing requires-clause - inline 'requires requires'.
    if (cpp20_concepts_lambda.run_inline_req(2, 3) != 5)
      throw new RuntimeException("run_inline_req(2, 3)");

    // 'mutable' followed by trailing requires-clause.
    if (cpp20_concepts_lambda.run_with_mut(4) != 8)
      throw new RuntimeException("run_with_mut(4)");

    // Prefix requires-clause on a templated lambda.
    if (cpp20_concepts_lambda.run_prefix(5) != 10)
      throw new RuntimeException("run_prefix(5)");

    // Prefix requires-clause on a templated lambda with no parameter list.
    if (cpp20_concepts_lambda.run_prefix_no_parms() != 7)
      throw new RuntimeException("run_prefix_no_parms()");

    // Trailing return type combined with a trailing requires-clause.
    if (cpp20_concepts_lambda.run_with_ret(6) != 12)
      throw new RuntimeException("run_with_ret(6)");

    // Both prefix and trailing requires-clauses on the same lambda.
    if (cpp20_concepts_lambda.run_both_clauses(3) != 6)
      throw new RuntimeException("run_both_clauses(3)");

    // Constrained auto parameter lambda - the 'Numeric auto' form.
    if (cpp20_concepts_lambda.run_auto_param(8) != 16)
      throw new RuntimeException("run_auto_param(8)");
  }
}

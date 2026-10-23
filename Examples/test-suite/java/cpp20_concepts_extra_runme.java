import cpp20_concepts_extra.*;

public class cpp20_concepts_extra_runme {

  static {
    try {
      System.loadLibrary("cpp20_concepts_extra");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // Negation via parens: '(!Numeric<T>)' on a non-numeric type.
    Tag t = new Tag(7);
    Tag out = cpp20_concepts_extra.identity_non_numeric_tag(t);
    if (out.value() != 7)
      throw new RuntimeException("identity_non_numeric_tag");

    // Multi parameter requires-expression with mixed types.
    if (cpp20_concepts_extra.mix_add_id(2, 3.5) != 5)
      throw new RuntimeException("mix_add_id(2, 3.5)");
    if (cpp20_concepts_extra.mix_add_id(-4, 1.0) != -3)
      throw new RuntimeException("mix_add_id(-4, 1.0)");

    // Variadic concept defined by a fold-expression over '&&'.
    if (cpp20_concepts_extra.sum_all_iii(1, 2, 3) != 6)
      throw new RuntimeException("sum_all_iii(1, 2, 3)");
    if (cpp20_concepts_extra.sum_all_iii(-5, 10, 2) != 7)
      throw new RuntimeException("sum_all_iii(-5, 10, 2)");
    if (cpp20_concepts_extra.sum_all_ddd(1.5, 2.5, 1.0) != 5.0)
      throw new RuntimeException("sum_all_ddd");

    // Type trait primary used as a constraint atom.
    if (cpp20_concepts_extra.trait_primary_int(7) != 14)
      throw new RuntimeException("trait_primary_int(7)");
    if (cpp20_concepts_extra.trait_primary_int(-3) != -6)
      throw new RuntimeException("trait_primary_int(-3)");

    // Deeper nesting of '&&' and '||' inside parens.
    if (cpp20_concepts_extra.deeper_int(42) != 42)
      throw new RuntimeException("deeper_int(42)");
    if (cpp20_concepts_extra.deeper_int(-7) != -7)
      throw new RuntimeException("deeper_int(-7)");

    // Both prefix AND trailing requires-clauses on the same function template.
    if (cpp20_concepts_extra.both_clauses_int(5) != 10)
      throw new RuntimeException("both_clauses_int(5)");
    if (cpp20_concepts_extra.both_clauses_int(-3) != -6)
      throw new RuntimeException("both_clauses_int(-3)");

    // Default template argument paired with a requires-clause.
    if (cpp20_concepts_extra.identity_default_int(7) != 7)
      throw new RuntimeException("identity_default_int(7)");
    if (cpp20_concepts_extra.identity_default_double(1.5) != 1.5)
      throw new RuntimeException("identity_default_double(1.5)");

    // Concept refinement - requires-clause spelled with a concept defined in terms of another.
    if (cpp20_concepts_extra.succ_int(5) != 6)
      throw new RuntimeException("succ_int(5)");

    // Trailing requires-clause on a non-template member of a class template.
    ConstrainedHolderInt h = new ConstrainedHolderInt(4);
    if (h.cube() != 64)
      throw new RuntimeException("ConstrainedHolderInt.cube");
  }
}

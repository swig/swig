import cpp20_concepts_constrained_param.*;

public class cpp20_concepts_constrained_param_runme {

  static {
    try {
      System.loadLibrary("cpp20_concepts_constrained_param");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // 1. Single type constrained parameter.
    if (cpp20_concepts_constrained_param.cube_int(3) != 27)
      throw new RuntimeException("cube_int");
    if (cpp20_concepts_constrained_param.cube_double(2.5) != 15.625)
      throw new RuntimeException("cube_double");

    // 2. ::-qualified concept-id.
    if (cpp20_concepts_constrained_param.half_int(10) != 5)
      throw new RuntimeException("half_int");

    // 3. Mixed type-constraint + plain typename.
    if (cpp20_concepts_constrained_param.scale_di(2.5, 4) != 10.0)
      throw new RuntimeException("scale_di");

    // 4. Default template argument paired with a type-constraint.
    if (cpp20_concepts_constrained_param.identity_int(7) != 7)
      throw new RuntimeException("identity_int");

    // 5. Two type-constraints in one head.
    if (cpp20_concepts_constrained_param.combine_id(40, (char)2) != 42)
      throw new RuntimeException("combine_id");

    // 6. Variadic type constrained pack.
    if (cpp20_concepts_constrained_param.count_numeric_1(1) != 1)
      throw new RuntimeException("count_numeric_1");
    if (cpp20_concepts_constrained_param.count_numeric_3(1, 2.0, (char)3) != 3)
      throw new RuntimeException("count_numeric_3");

    // 6a. Leading plain typename followed by a type constrained pack.
    if (cpp20_concepts_constrained_param.tag_count_si("hello", 1) != 1)
      throw new RuntimeException("tag_count_si");
    if (cpp20_concepts_constrained_param.tag_count_s3("hello", 1, 2.0, (char)3) != 3)
      throw new RuntimeException("tag_count_s3");

    // 6b. Two type-constraints with the trailing one a variadic pack.
    if (cpp20_concepts_constrained_param.small_tag_count_ci('x', 1) != 1)
      throw new RuntimeException("small_tag_count_ci");
    if (cpp20_concepts_constrained_param.small_tag_count_c3('x', 1, 2.0, (char)3) != 3)
      throw new RuntimeException("small_tag_count_c3");

    // 7. Constrained class template.
    BoxInt b = new BoxInt(11);
    if (b.get() != 11)
      throw new RuntimeException("BoxInt.get");
    b.set(42);
    if (b.get() != 42)
      throw new RuntimeException("BoxInt.set/get");

    BoxDouble bd = new BoxDouble(3.5);
    if (bd.get() != 3.5)
      throw new RuntimeException("BoxDouble.get");

    // 8. Constrained class template using a refining concept.
    FloatBoxFloat fb = new FloatBoxFloat(1.25f);
    if (fb.get() != 1.25f)
      throw new RuntimeException("FloatBoxFloat.get");

    // 9. Concept not parsed by SWIG.
    if (cpp20_concepts_constrained_param.tag_int(41) != 42)
      throw new RuntimeException("tag_int");

    // 10a. STL template-id concept-id.
    if (cpp20_concepts_constrained_param.to_int_d(3.5) != 3)
      throw new RuntimeException("to_int_d");

    // 10b. STL template-id concept-id on a class template.
    ConvertibleCrateDouble cc = new ConvertibleCrateDouble(4.25);
    if (cc.get() != 4)
      throw new RuntimeException("ConvertibleCrateDouble.get");

    // 10c. User defined 2-param concept in template-id form.
    if (cpp20_concepts_constrained_param.first_int_d(3.5) != 3)
      throw new RuntimeException("first_int_d");

    // 10d. Variadic template-id concept-id pack.
    if (cpp20_concepts_constrained_param.count_pair_1(1) != 1)
      throw new RuntimeException("count_pair_1");
    if (cpp20_concepts_constrained_param.count_pair_3(1, 2.0, 'x') != 3)
      throw new RuntimeException("count_pair_3");

    // 10e. Default template argument paired with a template-id concept-id.
    if (cpp20_concepts_constrained_param.with_default_int(42) != 42)
      throw new RuntimeException("with_default_int");
    if (cpp20_concepts_constrained_param.with_default_d(3.5) != 3)
      throw new RuntimeException("with_default_d");

    // 10f. Constrained class template with a template-id concept-id.
    CrateInt c = new CrateInt(5);
    if (c.get() != 5)
      throw new RuntimeException("CrateInt.get");
    CrateDouble cd = new CrateDouble(3.25);
    if (cd.get() != 3.25)
      throw new RuntimeException("CrateDouble.get");

    // 10g. ::-qualified template-id concept-id.
    if (cpp20_concepts_constrained_param.nested_pair_d(7.5) != 7)
      throw new RuntimeException("nested_pair_d");
  }
}

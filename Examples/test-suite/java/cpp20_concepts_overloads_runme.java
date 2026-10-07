import cpp20_concepts_overloads.*;

public class cpp20_concepts_overloads_runme {

  static {
    try {
      System.loadLibrary("cpp20_concepts_overloads");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // Function template overload by arity, each branch carrying the same
    // requires-clause.  All three arities dispatch correctly.
    if (cpp20_concepts_overloads.accumulate_int(5) != 6)
      throw new RuntimeException("accumulate_int(5)");
    if (cpp20_concepts_overloads.accumulate_int(5, 3) != 8)
      throw new RuntimeException("accumulate_int(5, 3)");
    if (cpp20_concepts_overloads.accumulate_int(1, 2, 3) != 6)
      throw new RuntimeException("accumulate_int(1, 2, 3)");

    if (cpp20_concepts_overloads.accumulate_double(2.5) != 3.5)
      throw new RuntimeException("accumulate_double(2.5)");
    if (cpp20_concepts_overloads.accumulate_double(1.5, 2.5) != 4.0)
      throw new RuntimeException("accumulate_double(1.5, 2.5)");
    if (cpp20_concepts_overloads.accumulate_double(0.5, 1.0, 2.5) != 4.0)
      throw new RuntimeException("accumulate_double(0.5, 1.0, 2.5)");

    // Function templates differing only by their requires-clause are both kept.  The doubling one
    // is the integral overload and the tripling one the floating point overload.
    if (cpp20_concepts_overloads.scale_int(5) != 10)
      throw new RuntimeException("scale_int(5)");
    if (cpp20_concepts_overloads.scale_double_to_int(3.5) != 7)
      throw new RuntimeException("scale_double_to_int(3.5)");

    // A declaration and a definition with the constraint spelt differently are wrapped as one function template.
    if (cpp20_concepts_overloads.respaced(5) != 6)
      throw new RuntimeException("respaced(5)");
    if (cpp20_concepts_overloads.respaced_requirement(5) != 7)
      throw new RuntimeException("respaced_requirement(5)");
    if (cpp20_concepts_overloads.renamed(5, 2.5) != 7)
      throw new RuntimeException("renamed(5, 2.5)");
    if (cpp20_concepts_overloads.reclosed(5) != 8)
      throw new RuntimeException("reclosed(5)");

    // Member function templates told apart by their ref-qualifier and cv-qualifier.
    Holder h = new Holder();
    h.setValue(10);
    if (h.get_int(5) != 15)
      throw new RuntimeException("Holder.get_int(5)");
    if (h.get_double(2.5) != -7.5)
      throw new RuntimeException("Holder.get_double(2.5)");

    // Member operator overloads with trailing requires-clauses.
    BoxInt a = new BoxInt(7);
    BoxInt b = new BoxInt(7);
    BoxInt c = new BoxInt(9);
    if (!a.eq(b))
      throw new RuntimeException("BoxInt.eq equal");
    if (a.eq(c))
      throw new RuntimeException("BoxInt.eq not equal");
    if (a.plus(c).getV() != 16)
      throw new RuntimeException("BoxInt.plus");

    BoxDouble ad = new BoxDouble(1.5);
    BoxDouble bd = new BoxDouble(1.5);
    BoxDouble cd = new BoxDouble(2.5);
    if (!ad.eq(bd))
      throw new RuntimeException("BoxDouble.eq equal");
    if (ad.eq(cd))
      throw new RuntimeException("BoxDouble.eq not equal");
    if (ad.plus(cd).getV() != 4.0)
      throw new RuntimeException("BoxDouble.plus");
  }
}

import c99_vla_typemaps.*;

public class c99_vla_typemaps_runme {

  static {
    try {
      System.loadLibrary("c99_vla_typemaps");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void check(String what, int i, int expected) {
    int actual = c99_vla_typemaps.seen_size(i);
    if (actual != expected)
      throw new RuntimeException(what + ": size " + i + " is " + actual + ", expected " + expected);
  }

  public static void main(String argv[]) {
    // Multi-argument typemaps
    c99_vla_typemaps.multi_star(2, null);
    check("multi_star", 0, 2);
    c99_vla_typemaps.multi_named(3, null);
    check("multi_named", 0, 3);
    c99_vla_typemaps.multi_plain(4, null);
    check("multi_plain", 0, -1);
    c99_vla_typemaps.multi_pair(5, null, null);
    check("multi_pair", 0, 5);
    check("multi_pair", 1, 5);

    // Multidimensional arrays
    c99_vla_typemaps.grid(2, 3, null);
    check("grid", 0, 2);
    check("grid", 1, 3);
    check("grid", 2, 6);
    c99_vla_typemaps.three_rows(5, null);
    check("three_rows", 0, 3);
    check("three_rows", 1, 5);
    check("three_rows", 2, 15);
    c99_vla_typemaps.four_columns(2, null);
    check("four_columns", 0, 2);
    check("four_columns", 1, 4);
    check("four_columns", 2, 8);

    // %apply and %clear
    c99_vla_typemaps.applied(6, null);
    check("applied", 0, 6);
    c99_vla_typemaps.cleared(7, null);
    check("cleared", 0, -1);

    // A typemap written with '[*]' comes before one for an array of unknown size
    c99_vla_typemaps.const_ints(8, null);
    check("const_ints", 0, 8);
    c99_vla_typemaps.my_shorts(9, null);
    check("my_shorts", 0, 9);
    c99_vla_typemaps.points(10, null);
    check("points", 0, 10);

    // Type variables
    c99_vla_typemaps.floats(11, null);
    if (!c99_vla_typemaps.seen_type().equals("float [] float (*)[]"))
      throw new RuntimeException("floats: type is " + c99_vla_typemaps.seen_type());

    // Sizes that are structure members
    Dims d = new Dims();
    d.setRows(2);
    d.setCols(3);
    c99_vla_typemaps.member_sizes(d, null);
    check("member_sizes", 0, 23);

    // Typedefs
    c99_vla_typemaps.typedef_longs(4, null);
    check("typedef_longs", 0, 4);
    c99_vla_typemaps.typedef_rows(5, null);
    check("typedef_rows", 0, 5);
    check("typedef_rows", 1, 3);
    check("typedef_rows", 2, 15);

    // A typemap written with the size as declared comes before one written with '[*]'
    c99_vla_typemaps.declared_named(2, null);
    check("declared_named", 0, 2);
    check("declared_named", 1, 1);
    c99_vla_typemaps.declared_unnamed(3, null);
    check("declared_unnamed", 0, 3);
    check("declared_unnamed", 1, 2);
    c99_vla_typemaps.declared_other(4, null);
    check("declared_other", 0, 4);
    check("declared_other", 1, 3);
    c99_vla_typemaps.declared_multi(5, null, 6);
    check("declared_multi", 0, 5);
    check("declared_multi", 1, 6);
    c99_vla_typemaps.declared_pointer(7, null);
    check("declared_pointer", 1, 4);

    // Ignored arguments at the start, in the middle and at the end
    int ignored = c99_vla_typemaps.ignored_arguments(3, 10);
    if (ignored != 133)
      throw new RuntimeException("ignored_arguments: " + ignored);
  }
}

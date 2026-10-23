import cpp17_inheriting_constructors_pack.*;

public class cpp17_inheriting_constructors_pack_runme {

  static {
    try {
	System.loadLibrary("cpp17_inheriting_constructors_pack");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void check(Object lhs, Object rhs) {
    if (!lhs.equals(rhs))
      throw new RuntimeException("'" + lhs + "' != '" + rhs + "'");
  }

  public static void main(String argv[]) {
    // Construct through each base's inherited constructor in turn and read back what was built through
    // the shared last_constructed() free function.  Before issue #3481 was fixed the last base's
    // constructor was dropped and a spurious Warning 526 was emitted.

    // Two-base pack: first and last pack element.
    new CombinedIS(7);
    check(cpp17_inheriting_constructors_pack.last_constructed(), "int:7");

    new CombinedIS("hello");
    check(cpp17_inheriting_constructors_pack.last_constructed(), "string:hello");

    // Three-base pack: the middle base (StringBase) and a last base (MultiBase) whose constructor has a
    // default argument, so MultiBase contributes two overloaded constructors that are inherited
    // alongside the IntBase and StringBase constructors.
    new CombinedISM(7);
    check(cpp17_inheriting_constructors_pack.last_constructed(), "int:7");

    new CombinedISM("hello");
    check(cpp17_inheriting_constructors_pack.last_constructed(), "string:hello");

    new CombinedISM(true, "x", 5);
    check(cpp17_inheriting_constructors_pack.last_constructed(), "multi:true:x:5");

    new CombinedISM(true, "x");   // third argument defaults to 10
    check(cpp17_inheriting_constructors_pack.last_constructed(), "multi:true:x:10");

    // Surrounded declares its own constructors either side of the using-declaration.  Both the
    // constructor before it and the one after it must survive alongside every inherited constructor.
    new SurroundedISM(1, 2);
    check(cpp17_inheriting_constructors_pack.last_constructed(), "before:1:2");

    new SurroundedISM(3, 4, 5);
    check(cpp17_inheriting_constructors_pack.last_constructed(), "after:3:4:5");

    new SurroundedISM(7);
    check(cpp17_inheriting_constructors_pack.last_constructed(), "int:7");

    new SurroundedISM("hello");
    check(cpp17_inheriting_constructors_pack.last_constructed(), "string:hello");

    new SurroundedISM(true, "x", 9);
    check(cpp17_inheriting_constructors_pack.last_constructed(), "multi:true:x:9");

    new SurroundedISM(true, "x");   // third argument defaults to 10
    check(cpp17_inheriting_constructors_pack.last_constructed(), "multi:true:x:10");
  }
}

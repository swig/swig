
import cpp11_using_typedef_template_member.*;

public class cpp11_using_typedef_template_member_runme {

  static {
    try {
        System.loadLibrary("cpp11_using_typedef_template_member");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void check(int actual, int expected) {
    if (actual != expected)
      throw new RuntimeException("expected '" + expected + "' but got '" + actual + "'");
  }

  private static OwnersInt makeOwners(int value) {
    OwnersInt o = new OwnersInt();
    o.setValue(value);
    return o;
  }

  public static void main(String argv[]) {
    // Members inherited via a using-declaration whose qualifier is a C++11 alias of the template base.
    ClusterAliasInt alias = new ClusterAliasInt();
    alias.setOwners(makeOwners(42));
    check(alias.getOwners().getValue(), 42);
    check(alias.total(makeOwners(8)), 50);

    // Members inherited via a using-declaration whose qualifier is a plain typedef of the template base.
    ClusterTypedefInt td = new ClusterTypedefInt();
    td.setOwners(makeOwners(42));
    check(td.getOwners().getValue(), 42);
    check(td.total(makeOwners(8)), 50);

    // Control: members inherited via a using-declaration naming the template base directly.
    ClusterDirectInt direct = new ClusterDirectInt();
    direct.setOwners(makeOwners(42));
    check(direct.getOwners().getValue(), 42);
    check(direct.total(makeOwners(8)), 50);
  }
}

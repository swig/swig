import using_duplicates.*;

public class using_duplicates_runme {

  static {
    try {
      System.loadLibrary("using_duplicates");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    UsedFromNS u = new UsedFromNS();
    u.setValue(42);

    ContainerUsedFromNS c = new ContainerUsedFromNS();
    c.set(u);
    if (c.get().getValue() != 42) throw new RuntimeException("get().value");
    if (c.getItem().getValue() != 42) throw new RuntimeException("item.value");
  }
}

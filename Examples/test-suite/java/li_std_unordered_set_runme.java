import li_std_unordered_set.*;

public class li_std_unordered_set_runme {

  static {
    try {
      System.loadLibrary("li_std_unordered_set");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) throws Throwable
  {
    StringUnorderedSet ss = new StringUnorderedSet();

    if (!ss.empty()) throw new RuntimeException("Test (1) failed");
    if (ss.size() != 0) throw new RuntimeException("Test (2) failed");
    if (ss.has("key")) throw new RuntimeException("Test (3) failed");
    if (ss.erase("key")) throw new RuntimeException("Test (4) failed");

    if (!ss.insert("key")) throw new RuntimeException("Test (5) failed");
    if (ss.insert("key")) throw new RuntimeException("Test (6) failed");
    if (!ss.has("key")) throw new RuntimeException("Test (7) failed");

    if (!ss.erase("key")) throw new RuntimeException("Test (8) failed");
    if (!ss.empty()) throw new RuntimeException("Test (9) failed");
    if (ss.size() != 0) throw new RuntimeException("Test (10) failed");

    if (!ss.insert("key1")) throw new RuntimeException("Test (11) failed");
    if (!ss.insert("key2")) throw new RuntimeException("Test (12) failed");
    if (!ss.insert("key3")) throw new RuntimeException("Test (13) failed");
    if (ss.size() != 3) throw new RuntimeException("Test (14) failed");

    ss.clear();
    if (!ss.empty()) throw new RuntimeException("Test (15) failed");
    if (ss.size() != 0) throw new RuntimeException("Test (16) failed");
  }
}

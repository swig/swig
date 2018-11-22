import li_std_unordered_map.*;

public class li_std_unordered_map_runme {

  static {
    try {
      System.loadLibrary("li_std_unordered_map");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) throws Throwable
  {
    StringIntUnorderedMap sim = new StringIntUnorderedMap();
    IntIntUnorderedMap iim = new IntIntUnorderedMap();

    if (!sim.empty()) throw new RuntimeException("Test (1) failed");
    if (!iim.empty()) throw new RuntimeException("Test (2) failed");

    if (sim.size() != 0) throw new RuntimeException("Test (3) failed");
    if (iim.size() != 0) throw new RuntimeException("Test (4) failed");

    try {
      sim.get("key");
      throw new RuntimeException("Test (5) failed");
    } catch (IndexOutOfBoundsException e) {
    }

    try {
      iim.get(1);
      throw new RuntimeException("Test (6) failed");
    } catch (IndexOutOfBoundsException e) {
    }

    sim.set("key", 1);
    iim.set(1, 1);

    if (sim.size() != 1) throw new RuntimeException("Test (7) failed");
    if (iim.size() != 1) throw new RuntimeException("Test (8) failed");

    sim.del("key");
    iim.del(1);

    if (sim.has_key("key")) throw new RuntimeException("Test (9) failed");
    if (iim.has_key(1)) throw new RuntimeException("Test (10) failed");

    if (!sim.empty()) throw new RuntimeException("Test (11) failed");
    if (!iim.empty()) throw new RuntimeException("Test (12) failed");
    if (sim.size() != 0) throw new RuntimeException("Test (13) failed");
    if (iim.size() != 0) throw new RuntimeException("Test (14) failed");

    try {
      sim.del("key");
      throw new RuntimeException("Test (15) failed");
    } catch (IndexOutOfBoundsException e) {
    }

    try {
      iim.del(1);
      throw new RuntimeException("Test (16) failed");
    } catch (IndexOutOfBoundsException e) {
    }

    sim.set("key", 1);
    iim.set(1, 1);

    if (sim.size() != 1) throw new RuntimeException("Test (17) failed");
    if (iim.size() != 1) throw new RuntimeException("Test (18) failed");

    sim.clear();
    iim.clear();

    if (sim.has_key("key")) throw new RuntimeException("Test (19) failed");
    if (iim.has_key(1)) throw new RuntimeException("Test (20) failed");

    if (!sim.empty()) throw new RuntimeException("Test (21) failed");
    if (!iim.empty()) throw new RuntimeException("Test (22) failed");
    if (sim.size() != 0) throw new RuntimeException("Test (23) failed");
    if (iim.size() != 0) throw new RuntimeException("Test (24) failed");

    sim.set("key", 1);
    sim.set("key2", 2);
    iim.set(1, 1);
    iim.set(2, 2);

    if (sim.get("key") != 1) throw new RuntimeException("Test (25) failed");
    if (sim.get("key2") != 2) throw new RuntimeException("Test (26) failed");
    if (iim.get(1) != 1) throw new RuntimeException("Test (27) failed");
    if (iim.get(2) != 2) throw new RuntimeException("Test (28) failed");

    sim.set("key", 3);
    iim.set(1, 3);

    if (sim.get("key") != 3) throw new RuntimeException("Test (29) failed");
    if (sim.get("key2") != 2) throw new RuntimeException("Test (30) failed");
    if (iim.get(1) != 3) throw new RuntimeException("Test (31) failed");
    if (iim.get(2) != 2) throw new RuntimeException("Test (32) failed");
  }
}

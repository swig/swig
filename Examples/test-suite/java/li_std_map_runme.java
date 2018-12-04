import li_std_map.*;

public class li_std_map_runme {

  static {
    try {
      System.loadLibrary("li_std_map");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void failTest(int testNum) throws Throwable {
    throw new RuntimeException("Test failed: " + testNum);
  }

  public static void checkThat(boolean mustBeTrue, int testNum) throws Throwable {
    if (!mustBeTrue) failTest(testNum);
  }

  public static void main(String argv[]) throws Throwable
  {
    java.util.AbstractMap<String, Integer> sim = new StringIntMap();
    java.util.AbstractMap<Integer, Integer> iim = new IntIntMap();

    checkThat(sim.isEmpty(), 1);
    checkThat(iim.isEmpty(), 2);
    checkThat(sim.size() == 0, 3);
    checkThat(iim.size() == 0, 4);

    checkThat(sim.get("key") == null, 5);
    checkThat(iim.get(1) == null, 6);

    checkThat(!sim.containsKey("key"), 7);
    checkThat(!iim.containsKey(1), 8);

    checkThat(sim.put("key", 2) == null, 9);
    checkThat(iim.put(1, 2) == null, 10);

  //   if (sim.size() != 1) throw new RuntimeException("Test (7) failed");
  //   if (iim.size() != 1) throw new RuntimeException("Test (8) failed");

  //   sim.remove("key");
  //   iim.remove(1);

  //   if (sim.containsKey("key")) throw new RuntimeException("Test (9) failed");
  //   if (iim.containsKey(1)) throw new RuntimeException("Test (10) failed");

  //   if (!sim.isEmpty()) throw new RuntimeException("Test (11) failed");
  //   if (!iim.isEmpty()) throw new RuntimeException("Test (12) failed");
  //   if (sim.size() != 0) throw new RuntimeException("Test (13) failed");
  //   if (iim.size() != 0) throw new RuntimeException("Test (14) failed");

  //   try {
  //     sim.remove("key");
  //     throw new RuntimeException("Test (15) failed");
  //   } catch (IndexOutOfBoundsException e) {
  //   }

  //   try {
  //     iim.remove(1);
  //     throw new RuntimeException("Test (16) failed");
  //   } catch (IndexOutOfBoundsException e) {
  //   }

  //   sim.put("key", 1);
  //   iim.put(1, 1);

  //   if (sim.size() != 1) throw new RuntimeException("Test (17) failed");
  //   if (iim.size() != 1) throw new RuntimeException("Test (18) failed");

  //   sim.clear();
  //   iim.clear();

  //   if (sim.containsKey("key")) throw new RuntimeException("Test (19) failed");
  //   if (iim.containsKey(1)) throw new RuntimeException("Test (20) failed");

  //   if (!sim.isEmpty()) throw new RuntimeException("Test (21) failed");
  //   if (!iim.isEmpty()) throw new RuntimeException("Test (22) failed");
  //   if (sim.size() != 0) throw new RuntimeException("Test (23) failed");
  //   if (iim.size() != 0) throw new RuntimeException("Test (24) failed");

  //   sim.put("key", 1);
  //   sim.put("key2", 2);
  //   iim.put(1, 1);
  //   iim.put(2, 2);

  //   if (sim.get("key") != 1) throw new RuntimeException("Test (25) failed");
  //   if (sim.get("key2") != 2) throw new RuntimeException("Test (26) failed");
  //   if (iim.get(1) != 1) throw new RuntimeException("Test (27) failed");
  //   if (iim.get(2) != 2) throw new RuntimeException("Test (28) failed");

  //   sim.put("key", 3);
  //   iim.put(1, 3);

  //   if (sim.get("key") != 3) throw new RuntimeException("Test (29) failed");
  //   if (sim.get("key2") != 2) throw new RuntimeException("Test (30) failed");
  //   if (iim.get(1) != 3) throw new RuntimeException("Test (31) failed");
  //   if (iim.get(2) != 2) throw new RuntimeException("Test (32) failed");
  }
}

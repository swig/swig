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

  public static void checkThat(boolean mustBeTrue) throws Throwable {
    if (!mustBeTrue) {
      // Index [2], since this function is one hop away from main, and [1] is the current method.
      throw new RuntimeException("Test failed at line number " + Thread.currentThread().getStackTrace()[2].getLineNumber());
    }
  }

  public static void main(String argv[]) throws Throwable
  {
    java.util.AbstractMap<String, Integer> sim = new StringIntMap();
    java.util.AbstractMap<Integer, Integer> iim = new IntIntMap();

    checkThat(sim.isEmpty());
    checkThat(iim.isEmpty());
    checkThat(sim.size() == 0);
    checkThat(iim.size() == 0);

    checkThat(sim.get("key") == null);
    checkThat(iim.get(1) == null);

    checkThat(!sim.containsKey("key"));
    checkThat(!iim.containsKey(1));

    checkThat(sim.put("key", 2) == null);
    checkThat(iim.put(1, 2) == null);

    checkThat(sim.size() == 1);
    checkThat(iim.size() == 1);
    checkThat(!sim.isEmpty());
    checkThat(!iim.isEmpty());

    checkThat(sim.get("key") == 2);
    checkThat(iim.get(1) == 2);

    checkThat(sim.remove("key") == 2);
    checkThat(iim.remove(1) == 2);

    checkThat(sim.isEmpty());
    checkThat(iim.isEmpty());
    checkThat(sim.size() == 0);
    checkThat(iim.size() == 0);

    checkThat(sim.get("key") == null);
    checkThat(iim.get(1) == null);

    checkThat(sim.remove("key") == null);
    checkThat(iim.remove(1) == null);

    checkThat(sim.put("key", 2) == null);
    checkThat(iim.put(1, 2) == null);

    sim.clear();
    iim.clear();
    checkThat(sim.isEmpty());
    checkThat(iim.isEmpty());

    checkThat(sim.put("key1", 1) == null);
    checkThat(iim.put(1, 1) == null);
    checkThat(sim.put("key2", 2) == null);
    checkThat(iim.put(2, 2) == null);

    checkThat(sim.size() == 2);
    checkThat(iim.size() == 2);
    checkThat(sim.get("key1") == 1);
    checkThat(iim.get(1) == 1);
    checkThat(sim.get("key2") == 2);
    checkThat(iim.get(2) == 2);

    checkThat(sim.put("key1", 3) == 1);
    checkThat(iim.put(1, 3) == 1);

    checkThat(sim.size() == 2);
    checkThat(iim.size() == 2);
    checkThat(sim.get("key1") == 3);
    checkThat(iim.get(1) == 3);

    java.util.Set<java.util.Map.Entry<String, Integer>> sim_es = sim.entrySet();
    java.util.Map<String, Integer> sim_default = new java.util.HashMap<String, Integer>();
    sim_default.put("key1", 3);
    sim_default.put("key2", 2);
    java.util.Set<java.util.Map.Entry<String, Integer>> sim_es_default = sim_default.entrySet();
    checkThat(sim_es.size() == sim_es_default.size());
    for (java.util.Map.Entry<String, Integer> entry : sim_es) {
      checkThat(sim_es_default.contains(entry));
      checkThat(sim_default.containsKey(entry.getKey()));
      checkThat(sim_default.containsValue(entry.getValue()));

      Integer oldValue = entry.getValue();
      entry.setValue(oldValue + 1);
      checkThat(sim.get(entry.getKey()) == (oldValue + 1));
    }

    java.util.Set<java.util.Map.Entry<Integer, Integer>> iim_es = iim.entrySet();
    java.util.Map<Integer, Integer> iim_default = new java.util.HashMap<Integer, Integer>();
    iim_default.put(1, 3);
    iim_default.put(2, 2);
    java.util.Set<java.util.Map.Entry<Integer, Integer>> iim_es_default = iim_default.entrySet();
    checkThat(iim_es.size() == iim_es_default.size());
    for (java.util.Map.Entry<Integer, Integer> entry : iim_es) {
      checkThat(iim_es_default.contains(entry));
      checkThat(iim_default.containsKey(entry.getKey()));
      checkThat(iim_default.containsValue(entry.getValue()));

      Integer oldValue = entry.getValue();
      entry.setValue(oldValue + 1);
      checkThat(iim.get(entry.getKey()) == (oldValue + 1));
    }
  }
}

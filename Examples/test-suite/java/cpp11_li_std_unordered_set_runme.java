import cpp11_li_std_unordered_set.*;

public class cpp11_li_std_unordered_set_runme {

  static {
    try {
      System.loadLibrary("cpp11_li_std_unordered_set");
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
    java.util.AbstractSet<String> ss = new StringUnorderedSet();

    checkThat(ss.isEmpty(), 1);
    checkThat(!ss.contains("key"), 2);
    checkThat(!ss.remove("key"), 3);

    checkThat(ss.add("key"), 4);
    checkThat(!ss.add("key"), 5);
    checkThat(ss.contains("key"), 6);
    checkThat(ss.remove("key"), 7);
    checkThat(ss.isEmpty(), 8);
    checkThat(ss.size() == 0, 9);

    checkThat(ss.add("key1"), 10);
    checkThat(ss.add("key2"), 11);
    checkThat(ss.add("key3"), 12);
    checkThat(ss.size() == 3, 13);

    ss.clear();
    checkThat(ss.isEmpty(), 14);
    checkThat(ss.size() == 0, 15);

    checkThat(ss.addAll(java.util.Arrays.asList("one", "two", "three")), 16);
    checkThat(ss.size() == 3, 17);
    checkThat(ss.contains("one"), 18);
    checkThat(!ss.contains("four"), 19);

    checkThat(ss.containsAll(java.util.Arrays.asList("one", "two", "three")), 20);
    checkThat(ss.containsAll(java.util.Arrays.asList("one", "two")), 21);
    checkThat(!ss.containsAll(java.util.Arrays.asList("one", "two", "four")), 22);
    checkThat(!ss.containsAll(java.util.Arrays.asList("one", "two", "three", "four")), 23);

    checkThat(!ss.addAll(java.util.Arrays.asList("one", "two", "three")), 24);

    java.util.Set<String> found = new java.util.HashSet<String>();
    java.util.Iterator<String> itr = ss.iterator();
    while (itr.hasNext()) {
      found.add(itr.next());
    }

    checkThat(ss.containsAll(found), 25);
    checkThat(found.containsAll(ss), 26);

    java.util.AbstractSet<String> ss2 = new StringUnorderedSet(ss);
    checkThat(ss2.containsAll(ss), 27);
    checkThat(ss.containsAll(ss2), 28);

    checkThat(!ss.removeAll(java.util.Arrays.asList("five", "four")), 29);
    checkThat(ss.removeAll(found), 30);
    checkThat(ss.isEmpty(), 31);
    checkThat(ss.size() == 0, 32);
  }
}

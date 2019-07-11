import li_std_set.*;

public class li_std_set_runme {

  static {
    try {
      System.loadLibrary("li_std_set");
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
    java.util.AbstractSet<String> ss = new StringSet();

    checkThat(ss.isEmpty());
    checkThat(!ss.contains("key"));
    checkThat(!ss.remove("key"));

    checkThat(ss.add("key"));
    checkThat(!ss.add("key"));
    checkThat(ss.contains("key"));
    checkThat(ss.remove("key"));
    checkThat(ss.isEmpty());
    checkThat(ss.size() == 0);

    checkThat(ss.add("key1"));
    checkThat(ss.add("key2"));
    checkThat(ss.add("key3"));
    checkThat(ss.size() == 3);

    ss.clear();
    checkThat(ss.isEmpty());
    checkThat(ss.size() == 0);

    checkThat(ss.addAll(java.util.Arrays.asList("one", "two", "three")));
    checkThat(ss.size() == 3);
    checkThat(ss.contains("one"));
    checkThat(!ss.contains("four"));

    checkThat(ss.containsAll(java.util.Arrays.asList("one", "two", "three")));
    checkThat(ss.containsAll(java.util.Arrays.asList("one", "two")));
    checkThat(!ss.containsAll(java.util.Arrays.asList("one", "two", "four")));
    checkThat(!ss.containsAll(java.util.Arrays.asList("one", "two", "three", "four")));

    checkThat(!ss.addAll(java.util.Arrays.asList("one", "two", "three")));

    java.util.Set<String> found = new java.util.HashSet<String>();
    java.util.Iterator<String> itr = ss.iterator();
    while (itr.hasNext()) {
      found.add(itr.next());
    }

    checkThat(ss.containsAll(found));
    checkThat(found.containsAll(ss));

    java.util.AbstractSet<String> ss2 = new StringSet(ss);
    checkThat(ss2.containsAll(ss));
    checkThat(ss.containsAll(ss2));

    checkThat(!ss.removeAll(java.util.Arrays.asList("five", "four")));
    checkThat(ss.removeAll(found));
    checkThat(ss.isEmpty());
    checkThat(ss.size() == 0);

    // Check a set of another type.
    java.util.AbstractSet<Foo> fooSet = new FooSet();
    checkThat(fooSet.isEmpty());
    checkThat(fooSet.add(new Foo(17)));
    checkThat(fooSet.size() == 1);

    // And a set of primitive type.
    java.util.AbstractSet<Integer> intSet = new IntSet();
    checkThat(intSet.isEmpty());
    checkThat(intSet.add(17));
    checkThat(!intSet.add(17));
    checkThat(intSet.size() == 1);
    checkThat(intSet.add(289));
    checkThat(intSet.size() == 2);
  }
}

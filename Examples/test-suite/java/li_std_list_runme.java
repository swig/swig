import li_std_list.*;

public class li_std_list_runme {

  static {
    try {
        System.loadLibrary("li_std_list");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) throws Throwable
  {
    IntList v1 = new IntList();
    DoubleList v2 = new DoubleList();

    if (!v1.isEmpty()) throw new RuntimeException("v1 test (1) failed");
    if (v1.size() != 0) throw new RuntimeException("v1 test (2) failed");
    if (!v1.add(123)) throw new RuntimeException("v1 test (3) failed");
    if (v1.size() != 1) throw new RuntimeException("v1 test (4) failed");
    if (v1.isEmpty()) throw new RuntimeException("v1 test (5) failed");

    int sum = 0;
    for (int n : v1) {
      if (n != 123) throw new RuntimeException("v1 loop test failed");
      sum += n;
    }
    if (sum != 123) throw new RuntimeException("v1 sum test failed");
    if (v1.get(0) != 123) throw new RuntimeException("v1 test failed");
    v1.clear();
    if (!v1.isEmpty()) throw new RuntimeException("v1 test clear failed");
    v1.add(123);

    if (v1.set(0, 456) != 123) throw new RuntimeException("v1 test (6) failed");
    if (v1.size() != 1) throw new RuntimeException("v1 test (7) failed");
    if (v1.get(0) != 456) throw new RuntimeException("v1 test (8) failed");

    java.util.Iterator<Integer> v1_iterator = v1.iterator();
    if (!v1_iterator.hasNext()) throw new RuntimeException("v1 test (9) failed");
    if (v1_iterator.next() != 456) throw new RuntimeException("v1 test (10) failed");
    if (v1_iterator.hasNext()) throw new RuntimeException("v1 test (11) failed");
    try {
      v1_iterator.next();
      throw new RuntimeException("v1 test (12) failed");
    } catch (java.util.NoSuchElementException e) {
    }

    if (v1.remove(new Integer(123))) throw new RuntimeException("v1 test (13) failed");
    if (!v1.remove(new Integer(456))) throw new RuntimeException("v1 test (14) failed");
    if (!v1.isEmpty()) throw new RuntimeException("v1 test (15) failed");
    if (v1.size() != 0) throw new RuntimeException("v1 test (16) failed");
    if (v1.remove(new Integer(456))) throw new RuntimeException("v1 test (17) failed");

    StructList v4 = new StructList();
    StructPtrList v5 = new StructPtrList();
    StructConstPtrList v6 = new StructConstPtrList();

    v4.add(new Struct(12));
    v5.add(new Struct(34));
    v6.add(new Struct(56));

    Struct s = null;
    if (v4.get(0).getNum() != 12) throw new RuntimeException("v4 test failed");
    if (v5.get(0).getNum() != 34) throw new RuntimeException("v5 test failed");
    if (v6.get(0).getNum() != 56) throw new RuntimeException("v6 test failed");
  }
}

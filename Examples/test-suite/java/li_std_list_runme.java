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

    if (v1.remove(Integer.valueOf(123))) throw new RuntimeException("v1 test (13) failed");
    if (!v1.remove(Integer.valueOf(456))) throw new RuntimeException("v1 test (14) failed");
    if (!v1.isEmpty()) throw new RuntimeException("v1 test (15) failed");
    if (v1.size() != 0) throw new RuntimeException("v1 test (16) failed");
    if (v1.remove(Integer.valueOf(456))) throw new RuntimeException("v1 test (17) failed");

    if (new IntList(3, 0).size() != 3) throw new RuntimeException("constructor initial size test failed");
    for (int n : new IntList(10, 999))
      if (n != 999) throw new RuntimeException("constructor initialization with value failed");
    for (int n : new IntList(new IntList(10, 999)))
      if (n != 999) throw new RuntimeException("copy constructor initialization with value failed");

    StructList v4 = new StructList();
    StructPtrList v5 = new StructPtrList();
    StructConstPtrList v6 = new StructConstPtrList();

    v4.add(new Struct(12));
    v5.add(new Struct(34));
    v6.add(new Struct(56));

    if (v4.get(0).getNum() != 12) throw new RuntimeException("v4 test failed");
    if (v5.get(0).getNum() != 34) throw new RuntimeException("v5 test failed");
    if (v6.get(0).getNum() != 56) throw new RuntimeException("v6 test failed");

    for (Struct s : v4) {
      if (s.getNum() != 12) throw new RuntimeException("v4 loop test failed");
    }
    for (Struct s : v5) {
      if (s.getNum() != 34) throw new RuntimeException("v5 loop test failed");
    }
    for (Struct s : v6) {
      if (s.getNum() != 56) throw new RuntimeException("v6 loop test failed");
    }

    StructList v7 = li_std_list.CopyContainerStruct(new StructList());
    v7.add(new Struct(1));
    v7.add(new Struct(23));
    v7.add(new Struct(456));
    v7.add(new Struct(7890));
    if (v7.size() != 4) throw new RuntimeException("v7 test (1) failed");
    {
      double[] a7 = {1, 23, 456, 7890};
      int i7 = 0;
      for (Struct s7 : v7) {
        if (s7.getNum() != a7[i7]) throw new RuntimeException("v7 test (2) failed");
        i7++;
      }
      if (i7 != a7.length) throw new RuntimeException("v7 test (3) failed");
    }
    if (v7.remove(2).getNum() != 456) throw new RuntimeException("v7 test (4) failed");
    {
      double[] a7 = {1, 23, 7890};
      int i7 = 0;
      for (Struct s7 : v7) {
        if (s7.getNum() != a7[i7]) throw new RuntimeException("v7 test (5) failed");
        i7++;
      }
      if (i7 != a7.length) throw new RuntimeException("v7 test (6) failed");
    }
    v7.add(1, new Struct(123));
    {
      double[] a7 = {1, 123, 23, 7890};
      int i7 = 0;
      for (Struct s7 : v7) {
        if (s7.getNum() != a7[i7]) throw new RuntimeException("v7 test (7) failed");
        i7++;
      }
      if (i7 != a7.length) throw new RuntimeException("v7 test (8) failed");
    }

    BoolList v8 = new BoolList();
    if (!v8.add(true)) throw new RuntimeException("v8 test (1) failed");;
    if (v8.get(0) != true) throw new RuntimeException("v8 test (2) failed");;
    if (v8.set(0, false) != true) throw new RuntimeException("v8 test (3) failed");;
    if (v8.set(0, false) != false) throw new RuntimeException("v8 test (4) failed");;
    if (v8.size() != 1) throw new RuntimeException("v8 test (5) failed");;

    java.util.ArrayList<Boolean> bl = new java.util.ArrayList<Boolean>(java.util.Arrays.asList(true, false, true, false));
    BoolList bv = new BoolList(java.util.Arrays.asList(true, false, true, false));
    BoolList bv2 = new BoolList(bl);
    java.util.ArrayList<Boolean> bl2 = new java.util.ArrayList<Boolean>(bv);
    boolean bbb1 = bv.get(0);
    Boolean bbb2 = bv.get(0);

    IntList v9 = new IntList(java.util.Arrays.asList(10, 20, 30, 40));
    v9.add(50);
    v9.add(60);
    v9.add(70);
    if (v9.size() != 7) throw new RuntimeException("v9 test (1) failed");
    if (!v9.remove(Integer.valueOf(60))) throw new RuntimeException("v9 test (2) failed");
    if (v9.size() != 6) throw new RuntimeException("v9 test (3) failed");
    v9.addFirst(-10);
    v9.addLast(80);
    if (v9.size() != 8) throw new RuntimeException("v9 test (4) failed");
    if (v9.get(0) != -10) throw new RuntimeException("v9 test (5) failed");;
    if (v9.get(v9.size()-1) != 80) throw new RuntimeException("v9 test (6) failed");;
    v9.removeFirst();
    if (v9.get(0) != 10) throw new RuntimeException("v9 test (7) failed");;
    v9.removeLast();
    if (v9.size() != 6) throw new RuntimeException("v9 test (8) failed");
    if (v9.get(v9.size()-1) != 70) throw new RuntimeException("v9 test (9) failed");;

    IntList v10 = new IntList(java.util.Arrays.asList(10, 20, 30, 40, 50));
    v10.subList(1, 4).clear(); // Recommended way to call protected method removeRange(1,3)
    if (v10.size() != 2) throw new RuntimeException("v10 test (1) failed");
    if (v10.get(0) != 10) throw new RuntimeException("v10 test (2) failed");
    if (v10.get(1) != 50) throw new RuntimeException("v10 test (3) failed");
    v10.addAll(1, java.util.Arrays.asList(22, 33));
    if (v10.size() != 4) throw new RuntimeException("v10 test (4) failed");
    if (v10.get(1) != 22) throw new RuntimeException("v10 test (5) failed");
    if (v10.get(2) != 33) throw new RuntimeException("v10 test (6) failed");

    v10.add(v10.size(), 55);
    if (v10.size() != 5) throw new RuntimeException("v10 test (7) failed");
    if (v10.get(4) != 55) throw new RuntimeException("v10 test (8) failed");

    IntList v11 = new IntList(java.util.Arrays.asList(11, 22, 33, 44));
    v11.listIterator(0);
    v11.listIterator(v11.size());
    try {
      v11.listIterator(v11.size() + 1);
      throw new RuntimeException("v11 test (1) failed");
    } catch (IndexOutOfBoundsException e) {
    }
    try {
      v11.listIterator(-1);
      throw new RuntimeException("v11 test (2) failed");
    } catch (IndexOutOfBoundsException e) {
    }
  }
}

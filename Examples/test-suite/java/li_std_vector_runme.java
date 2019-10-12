import li_std_vector.*;

public class li_std_vector_runme {

  static {
    try {
      System.loadLibrary("li_std_vector");
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
    IntVector v1 = li_std_vector.vecintptr(new IntVector());
    IntPtrVector v2 = li_std_vector.vecintptr(new IntPtrVector());
    IntConstPtrVector v3 = li_std_vector.vecintconstptr(new IntConstPtrVector());

    checkThat(v1.isEmpty());
    checkThat(v1.size() == 0);
    checkThat(v1.add(123));
    checkThat(v1.size() == 1);
    checkThat(!v1.isEmpty());

    int sum = 0;
    for (int n : v1) {
      checkThat(n == 123);
      sum += n;
    }
    checkThat(sum == 123);
    checkThat(v1.get(0) == 123);
    v1.clear();
    checkThat(v1.isEmpty());
    v1.add(123);

    checkThat(v1.set(0, 456) == 123);
    checkThat(v1.size() == 1);
    checkThat(v1.get(0) == 456);

    java.util.Iterator<Integer> v1_iterator = v1.iterator();
    checkThat(v1_iterator.hasNext());
    checkThat(v1_iterator.next() == 456);
    checkThat(!v1_iterator.hasNext());
    try {
      v1_iterator.next();
      checkThat(false);
    } catch (java.util.NoSuchElementException e) {
    }

    checkThat(!v1.remove(Integer.valueOf(123)));
    checkThat(v1.remove(Integer.valueOf(456)));
    checkThat(v1.isEmpty());
    checkThat(v1.size() == 0);
    checkThat(!v1.remove(Integer.valueOf(456)));

    checkThat(new IntVector(3, 0).size() == 3);
    for (int n : new IntVector(10, 999))
      checkThat(n == 999);
    for (int n : new IntVector(new IntVector(10, 999)))
      checkThat(n == 999);

    StructVector v4 = li_std_vector.vecstruct(new StructVector());
    StructPtrVector v5 = li_std_vector.vecstructptr(new StructPtrVector());
    StructConstPtrVector v6 = li_std_vector.vecstructconstptr(new StructConstPtrVector());

    v4.add(new Struct(12));
    v5.add(new Struct(34));
    v6.add(new Struct(56));

    checkThat(v4.get(0).getNum() == 12);
    checkThat(v5.get(0).getNum() == 34);
    checkThat(v6.get(0).getNum() == 56);

    for (Struct s : v4) {
      checkThat(s.getNum() == 12);
    }
    for (Struct s : v5) {
      checkThat(s.getNum() == 34);
    }
    for (Struct s : v6) {
      checkThat(s.getNum() == 56);
    }

    StructVector v7 = li_std_vector.vecstruct(new StructVector());
    v7.add(new Struct(1));
    v7.add(new Struct(23));
    v7.add(new Struct(456));
    v7.add(new Struct(7890));
    checkThat(v7.size() == 4);
    {
      double[] a7 = {1, 23, 456, 7890};
      int i7 = 0;
      for (Struct s7 : v7) {
        checkThat(s7.getNum() == a7[i7]);
        i7++;
      }
      checkThat(i7 == a7.length);
    }
    checkThat(v7.remove(2).getNum() == 456);
    {
      double[] a7 = {1, 23, 7890};
      int i7 = 0;
      for (Struct s7 : v7) {
        checkThat(s7.getNum() == a7[i7]);
        i7++;
      }
      checkThat(i7 == a7.length);
    }
    v7.add(1, new Struct(123));
    {
      double[] a7 = {1, 123, 23, 7890};
      int i7 = 0;
      for (Struct s7 : v7) {
        checkThat(s7.getNum() == a7[i7]);
        i7++;
      }
      checkThat(i7 == a7.length);
    }

    BoolVector v8 = new BoolVector();
    checkThat(v8.add(true));
    checkThat(v8.get(0) == true);
    checkThat(v8.set(0, false) == true);
    checkThat(v8.set(0, false) == false);
    checkThat(v8.size() == 1);

    java.util.ArrayList<Boolean> bl = new java.util.ArrayList<Boolean>(java.util.Arrays.asList(true, false, true, false));
    BoolVector bv = new BoolVector(java.util.Arrays.asList(true, false, true, false));
    BoolVector bv2 = new BoolVector(bl);
    java.util.ArrayList<Boolean> bl2 = new java.util.ArrayList<Boolean>(bv);
    boolean bbb1 = bv.get(0);
    Boolean bbb2 = bv.get(0);

    IntVector v9 = new IntVector(java.util.Arrays.asList(10, 20, 30, 40));
    v9.add(50);
    v9.add(60);
    v9.add(70);
    checkThat(v9.size() == 7);
    checkThat(v9.remove(Integer.valueOf(60)));
    checkThat(v9.size() == 6);

    IntVector v10 = new IntVector(java.util.Arrays.asList(10, 20, 30, 40, 50));
    v10.subList(1, 4).clear(); // Recommended way to call protected method removeRange(1,3)
    checkThat(v10.size() == 2);
    checkThat(v10.get(0) == 10);
    checkThat(v10.get(1) == 50);
    v10.addAll(1, java.util.Arrays.asList(22, 33));
    checkThat(v10.size() == 4);
    checkThat(v10.get(1) == 22);
    checkThat(v10.get(2) == 33);

    v10.add(v10.size(), 55);
    checkThat(v10.size() == 5);
    checkThat(v10.get(4) == 55);

    IntVector v11 = new IntVector(java.util.Arrays.asList(11, 22, 33, 44));
    v11.listIterator(0);
    v11.listIterator(v11.size());
    try {
      v11.listIterator(v11.size() + 1);
      checkThat(false);
    } catch (IndexOutOfBoundsException e) {
    }
    try {
      v11.listIterator(-1);
      checkThat(false);
    } catch (IndexOutOfBoundsException e) {
    }

    IntVector arrayInit = new IntVector(new int[]{1, 2, 3, 4, 5});
    checkThat(arrayInit.size() == 5);
    checkThat(arrayInit.get(0) == 1);
    checkThat(arrayInit.get(4) == 5);
  }
}

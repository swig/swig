import c99_vla_array_libraries.*;

public class c99_vla_array_libraries_runme {

  static {
    try {
      System.loadLibrary("c99_vla_array_libraries");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static Item newItem(int value) {
    Item item = new Item();
    item.setValue(value);
    return item;
  }

  public static void main(String argv[]) {
    if (c99_vla_array_libraries.sum_ints(3, new int[] {1, 2, 3}) != 6)
      throw new RuntimeException("sum_ints failed");
    if (c99_vla_array_libraries.sum_doubles(2, new double[] {0.5, 1.5}) != 2.0)
      throw new RuntimeException("sum_doubles failed");

    int[] numbers = {1, 2, 3};
    c99_vla_array_libraries.double_ints(3, numbers);
    if (numbers[0] != 2 || numbers[1] != 4 || numbers[2] != 6)
      throw new RuntimeException("double_ints failed");

    int[] colours = {Colour.GREEN.swigValue(), Colour.BLUE.swigValue()};
    if (c99_vla_array_libraries.sum_colours(2, colours) != 3)
      throw new RuntimeException("sum_colours failed");

    Item[] items = {newItem(10), newItem(20)};
    if (c99_vla_array_libraries.sum_items(2, items) != 30)
      throw new RuntimeException("sum_items failed");

    // An array that is not the size given at runtime is rejected
    boolean thrown = false;
    try {
      c99_vla_array_libraries.sum_ints(2, new int[] {1, 2, 3});
    } catch (IndexOutOfBoundsException e) {
      thrown = true;
    }
    if (!thrown)
      throw new RuntimeException("sum_ints with the wrong size did not throw");

    thrown = false;
    try {
      c99_vla_array_libraries.sum_items(3, items);
    } catch (IndexOutOfBoundsException e) {
      thrown = true;
    }
    if (!thrown)
      throw new RuntimeException("sum_items with the wrong size did not throw");
  }
}

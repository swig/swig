import volatile_qualifiers.*;

public class volatile_qualifiers_runme {
  static {
    try {
      System.loadLibrary("volatile_qualifiers");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void check(int actual, int expected) {
    if (actual != expected)
      throw new RuntimeException("Expected " + expected + " but got " + actual);
  }

  private static void check(String actual, String expected) {
    if (!actual.equals(expected))
      throw new RuntimeException("Expected " + expected + " but got " + actual);
  }

  public static void main(String argv[]) {
    SWIGTYPE_p_int p = volatile_qualifiers.volatile_int_ptr_return();
    check(volatile_qualifiers.int_ptr(p), 50);
    check(volatile_qualifiers.const_int_ptr(p), 50);
    check(volatile_qualifiers.volatile_int_ptr(p), 50);
    check(volatile_qualifiers.const_volatile_int_ptr(p), 50);
    check(volatile_qualifiers.int_volatile_ptr(p), 50);
    check(volatile_qualifiers.volatile_int_value(5), 5);
    check(volatile_qualifiers.const_volatile_int_value(6), 6);
    check(volatile_qualifiers.volatile_int_ref(p), 50);
    check(volatile_qualifiers.const_volatile_int_ref(6), 6);

    check(volatile_qualifiers.char_ptr("four"), 4);
    check(volatile_qualifiers.const_char_ptr("three"), 5);
    check(volatile_qualifiers.volatile_char_ptr("four"), 4);
    check(volatile_qualifiers.const_volatile_char_ptr("four"), 4);
    check(volatile_qualifiers.char_volatile_ptr("four"), 4);

    Item item = new Item(7);
    check(volatile_qualifiers.item_ptr(item), 7);
    check(volatile_qualifiers.const_item_ptr(item), 7);
    check(volatile_qualifiers.volatile_item_ptr(item), 7);
    check(volatile_qualifiers.const_volatile_item_ptr(item), 7);
    check(volatile_qualifiers.item_volatile_ptr(item), 7);
    check(volatile_qualifiers.volatile_item_ref(item), 7);
    check(volatile_qualifiers.const_volatile_item_ref(item), 7);

    check(volatile_qualifiers.const_volatile_char_ptr_return(), "return");
    check(volatile_qualifiers.volatile_item_ptr_return(item).getX(), 7);
    check(volatile_qualifiers.const_volatile_item_ref_return(item).getX(), 7);

    volatile_qualifiers.setGlobal_volatile_int(3);
    check(volatile_qualifiers.getGlobal_volatile_int(), 3);
    check(volatile_qualifiers.getGlobal_const_volatile_int(), 2);
    volatile_qualifiers.setGlobal_char_volatile_ptr("four");
    check(volatile_qualifiers.getGlobal_char_volatile_ptr(), "four");
    volatile_qualifiers.setGlobal_item_volatile_ptr(item);
    check(volatile_qualifiers.getGlobal_item_volatile_ptr().getX(), 7);
    volatile_qualifiers.setGlobal_volatile_int_ptr(p);
    check(volatile_qualifiers.int_ptr(volatile_qualifiers.getGlobal_volatile_int_ptr()), 50);
    volatile_qualifiers.setGlobal_volatile_item_ptr(item);
    check(volatile_qualifiers.getGlobal_volatile_item_ptr().getX(), 7);
    check(volatile_qualifiers.getGlobal_const_volatile_char_const_ptr(), "global");

    Members m = new Members();
    check(m.getVolatile_int(), 10);
    m.setVolatile_int(11);
    check(m.getVolatile_int(), 11);
    check(m.getConst_volatile_int(), 20);
    m.setChar_volatile_ptr("four");
    check(m.getChar_volatile_ptr(), "four");
    m.setVolatile_item_ptr(item);
    check(m.getVolatile_item_ptr().getX(), 7);
    m.setItem_volatile_ptr(item);
    check(m.getItem_volatile_ptr().getX(), 7);

    check(Members.getStatic_volatile_int(), 30);
    Members.setStatic_volatile_int(31);
    check(Members.getStatic_volatile_int(), 31);
    check(Members.getStatic_const_volatile_int(), 40);
    Members.setStatic_char_volatile_ptr("four");
    check(Members.getStatic_char_volatile_ptr(), "four");
    Members.setStatic_item_volatile_ptr(item);
    check(Members.getStatic_item_volatile_ptr().getX(), 7);
  }
}

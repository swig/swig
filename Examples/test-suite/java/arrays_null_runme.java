import arrays_null.*;

public class arrays_null_runme {
  static {
    try {
      System.loadLibrary("arrays_null");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    ArraysNull s = new ArraysNull();
    ArraysNull other = new ArraysNull();
    arrays_null.arrays_null_fill(other, 10);
    s.setInts(other.getInts());
    s.setItems(other.getItems());
    s.setGrid(other.getGrid());
    if (arrays_null.arrays_null_check(s, 10) != 1)
      throw new RuntimeException("Test member set failed");

    try {
      s.setInts(null);
      throw new RuntimeException("Test ints member set to null failed");
    } catch (NullPointerException e) {
    }
    try {
      s.setItems(null);
      throw new RuntimeException("Test items member set to null failed");
    } catch (NullPointerException e) {
    }
    try {
      s.setGrid(null);
      throw new RuntimeException("Test grid member set to null failed");
    } catch (NullPointerException e) {
    }
    if (arrays_null.arrays_null_check(s, 10) != 1)
      throw new RuntimeException("Test member set to null changed it");

    arrays_null.setArrays_null_ints(s.getInts());
    arrays_null.setArrays_null_items(s.getItems());
    arrays_null.setArrays_null_grid(s.getGrid());
    if (arrays_null.arrays_null_globals_check(10) != 1)
      throw new RuntimeException("Test global set failed");

    try {
      arrays_null.setArrays_null_ints(null);
      throw new RuntimeException("Test ints global set to null failed");
    } catch (NullPointerException e) {
    }
    try {
      arrays_null.setArrays_null_items(null);
      throw new RuntimeException("Test items global set to null failed");
    } catch (NullPointerException e) {
    }
    try {
      arrays_null.setArrays_null_grid(null);
      throw new RuntimeException("Test grid global set to null failed");
    } catch (NullPointerException e) {
    }
    try {
      arrays_null.setArrays_null_ints_ref(null);
      throw new RuntimeException("Test ints_ref global set to null failed");
    } catch (NullPointerException e) {
    }
    try {
      arrays_null.setArrays_null_bools(null);
      throw new RuntimeException("Test bools global set to null failed");
    } catch (NullPointerException e) {
    }
    if (arrays_null.arrays_null_globals_check(10) != 1)
      throw new RuntimeException("Test global set to null changed it");

    if (arrays_null.arrays_null_ints_isnull(null) != 1)
      throw new RuntimeException("Test null ints parameter failed");
    if (arrays_null.arrays_null_ints_unsized_isnull(null) != 1)
      throw new RuntimeException("Test null ints unsized parameter failed");
    if (arrays_null.arrays_null_enums_isnull(null) != 1)
      throw new RuntimeException("Test null enums parameter failed");
    if (arrays_null.arrays_null_enums_unsized_isnull(null) != 1)
      throw new RuntimeException("Test null enums unsized parameter failed");
    if (arrays_null.arrays_null_items_isnull(null) != 1)
      throw new RuntimeException("Test null items parameter failed");
    if (arrays_null.arrays_null_items_unsized_isnull(null) != 1)
      throw new RuntimeException("Test null items unsized parameter failed");
    if (arrays_null.arrays_null_bools_isnull(null) != 1)
      throw new RuntimeException("Test null bools parameter failed");
    if (arrays_null.arrays_null_bools_unsized_isnull(null) != 1)
      throw new RuntimeException("Test null bools unsized parameter failed");
    if (arrays_null.arrays_null_chars_isnull(null) != 1)
      throw new RuntimeException("Test null chars parameter failed");
    if (arrays_null.arrays_null_chars_unsized_isnull(null) != 1)
      throw new RuntimeException("Test null chars unsized parameter failed");
    if (arrays_null.arrays_null_strings_isnull(null) != 1)
      throw new RuntimeException("Test null strings parameter failed");
    if (arrays_null.arrays_null_strings_unsized_isnull(null) != 1)
      throw new RuntimeException("Test null strings unsized parameter failed");

    // A reference to an array cannot be null
    try {
      arrays_null.arrays_null_ints_ref_first(null);
      throw new RuntimeException("Test null ints_ref parameter failed");
    } catch (NullPointerException e) {
    }
  }
}

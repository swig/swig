using System;
using arrays_nullNamespace;

public class arrays_null_runme {
  public static void Main() {
    ArraysNull s = new ArraysNull();
    ArraysNull other = new ArraysNull();
    arrays_null.arrays_null_fill(other, 10);
    s.ints = other.ints;
    s.items = other.items;
    s.grid = other.grid;
    if (arrays_null.arrays_null_check(s, 10) != 1)
      throw new Exception("Test member set failed");

    try {
      s.ints = null;
      throw new Exception("Test ints member set to null failed");
    } catch (ArgumentNullException) {
    }
    try {
      s.items = null;
      throw new Exception("Test items member set to null failed");
    } catch (ArgumentNullException) {
    }
    try {
      s.grid = null;
      throw new Exception("Test grid member set to null failed");
    } catch (ArgumentNullException) {
    }
    if (arrays_null.arrays_null_check(s, 10) != 1)
      throw new Exception("Test member set to null changed it");

    arrays_null.arrays_null_ints = s.ints;
    arrays_null.arrays_null_items = s.items;
    arrays_null.arrays_null_grid = s.grid;
    if (arrays_null.arrays_null_globals_check(10) != 1)
      throw new Exception("Test global set failed");

    try {
      arrays_null.arrays_null_ints = null;
      throw new Exception("Test ints global set to null failed");
    } catch (ArgumentNullException) {
    }
    try {
      arrays_null.arrays_null_items = null;
      throw new Exception("Test items global set to null failed");
    } catch (ArgumentNullException) {
    }
    try {
      arrays_null.arrays_null_grid = null;
      throw new Exception("Test grid global set to null failed");
    } catch (ArgumentNullException) {
    }
    try {
      arrays_null.arrays_null_ints_ref = null;
      throw new Exception("Test ints_ref global set to null failed");
    } catch (ArgumentNullException) {
    }
    try {
      arrays_null.arrays_null_bools = null;
      throw new Exception("Test bools global set to null failed");
    } catch (ArgumentNullException) {
    }
    if (arrays_null.arrays_null_globals_check(10) != 1)
      throw new Exception("Test global set to null changed it");

    if (arrays_null.arrays_null_ints_isnull(null) != 1)
      throw new Exception("Test null ints parameter failed");
    if (arrays_null.arrays_null_ints_unsized_isnull(null) != 1)
      throw new Exception("Test null ints unsized parameter failed");
    if (arrays_null.arrays_null_enums_isnull(null) != 1)
      throw new Exception("Test null enums parameter failed");
    if (arrays_null.arrays_null_enums_unsized_isnull(null) != 1)
      throw new Exception("Test null enums unsized parameter failed");
    if (arrays_null.arrays_null_items_isnull(null) != 1)
      throw new Exception("Test null items parameter failed");
    if (arrays_null.arrays_null_items_unsized_isnull(null) != 1)
      throw new Exception("Test null items unsized parameter failed");
    if (arrays_null.arrays_null_bools_isnull(null) != 1)
      throw new Exception("Test null bools parameter failed");
    if (arrays_null.arrays_null_bools_unsized_isnull(null) != 1)
      throw new Exception("Test null bools unsized parameter failed");
    if (arrays_null.arrays_null_chars_isnull(null) != 1)
      throw new Exception("Test null chars parameter failed");
    if (arrays_null.arrays_null_chars_unsized_isnull(null) != 1)
      throw new Exception("Test null chars unsized parameter failed");
    if (arrays_null.arrays_null_strings_isnull(null) != 1)
      throw new Exception("Test null strings parameter failed");
    if (arrays_null.arrays_null_strings_unsized_isnull(null) != 1)
      throw new Exception("Test null strings unsized parameter failed");

    // A reference to an array cannot be null
    try {
      arrays_null.arrays_null_ints_ref_first(null);
      throw new Exception("Test null ints_ref parameter failed");
    } catch (ArgumentNullException) {
    }
  }
}

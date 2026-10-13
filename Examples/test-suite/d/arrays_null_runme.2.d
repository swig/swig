module arrays_null_runme;

import std.exception;
import arrays_null.arrays_null;
import arrays_null.ArraysNull;

void main() {
  auto s = new ArraysNull();
  auto other = new ArraysNull();
  arrays_null_fill(other, 10);
  s.ints = other.ints;
  s.items = other.items;
  s.grid = other.grid;
  enforce(arrays_null_check(s, 10) == 1, "Test member set failed");

  enforce(collectException(s.ints = null) !is null, "Test ints member set to null failed");
  enforce(collectException(s.items = null) !is null, "Test items member set to null failed");
  enforce(collectException(s.grid = null) !is null, "Test grid member set to null failed");
  enforce(arrays_null_check(s, 10) == 1, "Test member set to null changed it");

  arrays_null_ints = s.ints;
  arrays_null_items = s.items;
  arrays_null_grid = s.grid;
  enforce(arrays_null_globals_check(10) == 1, "Test global set failed");

  enforce(collectException(arrays_null_ints = null) !is null, "Test ints global set to null failed");
  enforce(collectException(arrays_null_items = null) !is null, "Test items global set to null failed");
  enforce(collectException(arrays_null_grid = null) !is null, "Test grid global set to null failed");
  enforce(collectException(arrays_null_ints_ref = null) !is null, "Test ints_ref global set to null failed");
  enforce(collectException(arrays_null_bools = null) !is null, "Test bools global set to null failed");
  enforce(arrays_null_globals_check(10) == 1, "Test global set to null changed it");

  enforce(arrays_null_ints_isnull(null) == 1, "Test null ints parameter failed");
  enforce(arrays_null_ints_unsized_isnull(null) == 1, "Test null ints unsized parameter failed");
  enforce(arrays_null_enums_isnull(null) == 1, "Test null enums parameter failed");
  enforce(arrays_null_enums_unsized_isnull(null) == 1, "Test null enums unsized parameter failed");
  enforce(arrays_null_items_isnull(null) == 1, "Test null items parameter failed");
  enforce(arrays_null_items_unsized_isnull(null) == 1, "Test null items unsized parameter failed");
  enforce(arrays_null_bools_isnull(null) == 1, "Test null bools parameter failed");
  enforce(arrays_null_bools_unsized_isnull(null) == 1, "Test null bools unsized parameter failed");
  enforce(arrays_null_chars_isnull(null) == 1, "Test null chars parameter failed");
  enforce(arrays_null_chars_unsized_isnull(null) == 1, "Test null chars unsized parameter failed");
  enforce(arrays_null_strings_isnull(null) == 1, "Test null strings parameter failed");
  enforce(arrays_null_strings_unsized_isnull(null) == 1, "Test null strings unsized parameter failed");

  // A reference to an array cannot be null
  enforce(collectException(arrays_null_ints_ref_first(null)) !is null, "Test null ints_ref parameter failed");
}

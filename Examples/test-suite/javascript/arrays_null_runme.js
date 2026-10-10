var arrays_null = require("arrays_null");

function check_set_null_fails(obj, name) {
  var threw = false;
  try {
    obj[name] = null;
  } catch (e) {
    if (e.message.indexOf("invalid null reference") === -1)
      throw e;
    threw = true;
  }
  if (!threw)
    throw new Error(name + " set to null did not throw");
}

var s = new arrays_null.ArraysNull();
var other = new arrays_null.ArraysNull();
arrays_null.arrays_null_fill(other, 10);
s.ints = other.ints;
s.items = other.items;
s.grid = other.grid;
if (arrays_null.arrays_null_check(s, 10) !== 1)
  throw new Error("member set");

check_set_null_fails(s, "ints");
check_set_null_fails(s, "items");
check_set_null_fails(s, "grid");
if (arrays_null.arrays_null_check(s, 10) !== 1)
  throw new Error("member set to null changed it");

arrays_null.arrays_null_ints = s.ints;
arrays_null.arrays_null_items = s.items;
arrays_null.arrays_null_grid = s.grid;
if (arrays_null.arrays_null_globals_check(10) !== 1)
  throw new Error("global set");

check_set_null_fails(arrays_null, "arrays_null_ints");
check_set_null_fails(arrays_null, "arrays_null_items");
check_set_null_fails(arrays_null, "arrays_null_grid");
check_set_null_fails(arrays_null, "arrays_null_ints_ref");
check_set_null_fails(arrays_null, "arrays_null_bools");
if (arrays_null.arrays_null_globals_check(10) !== 1)
  throw new Error("global set to null changed it");

if (arrays_null.arrays_null_ints_isnull(null) !== 1)
  throw new Error("ints_isnull");
if (arrays_null.arrays_null_ints_unsized_isnull(null) !== 1)
  throw new Error("ints_unsized_isnull");
if (arrays_null.arrays_null_enums_isnull(null) !== 1)
  throw new Error("enums_isnull");
if (arrays_null.arrays_null_enums_unsized_isnull(null) !== 1)
  throw new Error("enums_unsized_isnull");
if (arrays_null.arrays_null_items_isnull(null) !== 1)
  throw new Error("items_isnull");
if (arrays_null.arrays_null_items_unsized_isnull(null) !== 1)
  throw new Error("items_unsized_isnull");
if (arrays_null.arrays_null_bools_isnull(null) !== 1)
  throw new Error("bools_isnull");
if (arrays_null.arrays_null_bools_unsized_isnull(null) !== 1)
  throw new Error("bools_unsized_isnull");
if (arrays_null.arrays_null_chars_isnull(null) !== 1)
  throw new Error("chars_isnull");
if (arrays_null.arrays_null_chars_unsized_isnull(null) !== 1)
  throw new Error("chars_unsized_isnull");
if (arrays_null.arrays_null_strings_isnull(null) !== 1)
  throw new Error("strings_isnull");
if (arrays_null.arrays_null_strings_unsized_isnull(null) !== 1)
  throw new Error("strings_unsized_isnull");

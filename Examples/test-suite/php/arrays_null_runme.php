<?php

require "tests.php";

function check_null_rejected($name, $f) {
  try {
    $f();
    check::fail("$name set to null accepted");
  } catch (TypeError $e) {
  }
}

$s = new ArraysNull();
$other = new ArraysNull();
arrays_null_fill($other, 10);
$s->ints = $other->ints;
$s->items = $other->items;
$s->grid = $other->grid;
check::equal(arrays_null_check($s, 10), 1, "failed member set");

check_null_rejected("ints member", fn() => $s->ints = null);
check_null_rejected("items member", fn() => $s->items = null);
check_null_rejected("grid member", fn() => $s->grid = null);
check::equal(arrays_null_check($s, 10), 1, "failed member set to null");

arrays_null_ints_set($s->ints);
arrays_null_items_set($s->items);
arrays_null_grid_set($s->grid);
check::equal(arrays_null_globals_check(10), 1, "failed global set");

check_null_rejected("ints global", fn() => arrays_null_ints_set(null));
check_null_rejected("items global", fn() => arrays_null_items_set(null));
check_null_rejected("grid global", fn() => arrays_null_grid_set(null));
check_null_rejected("ints_ref global", fn() => arrays_null_ints_ref_set(null));
check_null_rejected("bools global", fn() => arrays_null_bools_set(null));
check::equal(arrays_null_globals_check(10), 1, "failed global set to null");

check::equal(arrays_null_ints_isnull(null), 1, "failed null ints array parameter");
check::equal(arrays_null_ints_unsized_isnull(null), 1, "failed null unsized ints array parameter");
check::equal(arrays_null_enums_isnull(null), 1, "failed null enums array parameter");
check::equal(arrays_null_enums_unsized_isnull(null), 1, "failed null unsized enums array parameter");
check::equal(arrays_null_items_isnull(null), 1, "failed null items array parameter");
check::equal(arrays_null_items_unsized_isnull(null), 1, "failed null unsized items array parameter");
check::equal(arrays_null_bools_isnull(null), 1, "failed null bools array parameter");
check::equal(arrays_null_bools_unsized_isnull(null), 1, "failed null unsized bools array parameter");
check::equal(arrays_null_chars_isnull(null), 1, "failed null chars array parameter");
check::equal(arrays_null_chars_unsized_isnull(null), 1, "failed null unsized chars array parameter");
check::equal(arrays_null_strings_isnull(null), 1, "failed null strings array parameter");
check::equal(arrays_null_strings_unsized_isnull(null), 1, "failed null unsized strings array parameter");

// A reference to an array cannot be null
check_null_rejected("ints_ref parameter", fn() => arrays_null_ints_ref_first(null));

check::done();

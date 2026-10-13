exec("swigtest.start", -1);

NULL = SWIG_ptr(0);

// An empty matrix is also NULL for an array of bools or strings, so is rejected for a variable
checkequal(arrays_null_bools_isnull([%t %f %t %f]), 0, "arrays_null_bools_isnull([%t %f %t %f])");
checkequal(arrays_null_bools_isnull([]), 1, "arrays_null_bools_isnull([])");
checkequal(arrays_null_bools_unsized_isnull([]), 1, "arrays_null_bools_unsized_isnull([])");
checkequal(arrays_null_strings_isnull(["a" "b" "c"]), 0, "arrays_null_strings_isnull([""a"" ""b"" ""c""])");
checkequal(arrays_null_strings_isnull([]), 1, "arrays_null_strings_isnull([])");
checkequal(arrays_null_strings_unsized_isnull([]), 1, "arrays_null_strings_unsized_isnull([])");
arrays_null_bools_set([%t %f]);
ierr = execstr("arrays_null_bools_set([])", "errcatch");
if ierr == 0 then swigtesterror("arrays_null_bools_set([]) error expected"); end
checkequal(arrays_null_bools_get(), [%t %f], "arrays_null_bools_get() after set to []");

s = new_ArraysNull();
other = new_ArraysNull();
arrays_null_fill(other, 10);
ArraysNull_ints_set(s, ArraysNull_ints_get(other));
ArraysNull_items_set(s, ArraysNull_items_get(other));
ArraysNull_grid_set(s, ArraysNull_grid_get(other));
checkequal(arrays_null_check(s, 10), 1, "arrays_null_check() after member set");

arrays_null_ints_set(ArraysNull_ints_get(s));
arrays_null_items_set(ArraysNull_items_get(s));
arrays_null_grid_set(ArraysNull_grid_get(s));
checkequal(arrays_null_globals_check(10), 1, "arrays_null_globals_check() after global set");

// NULL, an empty matrix for an array of numbers, is rejected, as is NULL for a reference to an array
null_calls = ["ArraysNull_ints_set(s, [])", "ArraysNull_items_set(s, NULL)", "ArraysNull_grid_set(s, NULL)", ..
              "arrays_null_ints_set([])", "arrays_null_items_set(NULL)", "arrays_null_grid_set(NULL)", ..
              "arrays_null_ints_ref_set(NULL)", "arrays_null_ints_ref_first(NULL)"];
for i = 1:size(null_calls, "*")
  ierr = execstr(null_calls(i), "errcatch");
  if ierr == 0 then swigtesterror(null_calls(i) + " error expected"); end
end
checkequal(arrays_null_check(s, 10), 1, "arrays_null_check() after member set to NULL");
checkequal(arrays_null_globals_check(10), 1, "arrays_null_globals_check() after global set to NULL");

// NULL is an empty matrix for an array of numbers and a NULL pointer for an array of enums or classes
checkequal(arrays_null_ints_isnull([]), 1, "arrays_null_ints_isnull([])");
checkequal(arrays_null_ints_unsized_isnull([]), 1, "arrays_null_ints_unsized_isnull([])");
checkequal(arrays_null_enums_isnull(NULL), 1, "arrays_null_enums_isnull(NULL)");
checkequal(arrays_null_enums_unsized_isnull(NULL), 1, "arrays_null_enums_unsized_isnull(NULL)");
checkequal(arrays_null_items_isnull(NULL), 1, "arrays_null_items_isnull(NULL)");
checkequal(arrays_null_items_unsized_isnull(NULL), 1, "arrays_null_items_unsized_isnull(NULL)");

delete_ArraysNull(other);
delete_ArraysNull(s);

exec("swigtest.quit", -1);

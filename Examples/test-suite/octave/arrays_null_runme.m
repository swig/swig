# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

arrays_null

function check_set_null_fails(obj, name)
  try
    obj.(name) = [];
  catch e
    if (isempty(strfind(e.message, "invalid null reference"))); rethrow(e); endif
    return;
  end_try_catch
  error("%s set to NULL did not fail", name);
end

null = []; # NULL pointer

s = arrays_null.ArraysNull();
other = arrays_null.ArraysNull();
arrays_null.arrays_null_fill(other, 10);
s.ints = other.ints;
s.items = other.items;
s.grid = other.grid;
if (arrays_null.arrays_null_check(s, 10) != 1); error("member set"); endif

check_set_null_fails(s, "ints");
check_set_null_fails(s, "items");
check_set_null_fails(s, "grid");
if (arrays_null.arrays_null_check(s, 10) != 1); error("member set to NULL changed it"); endif

arrays_null.cvar.arrays_null_ints = s.ints;
arrays_null.cvar.arrays_null_items = s.items;
arrays_null.cvar.arrays_null_grid = s.grid;
if (arrays_null.arrays_null_globals_check(10) != 1); error("global set"); endif

check_set_null_fails(arrays_null.cvar, "arrays_null_ints");
check_set_null_fails(arrays_null.cvar, "arrays_null_items");
check_set_null_fails(arrays_null.cvar, "arrays_null_grid");
check_set_null_fails(arrays_null.cvar, "arrays_null_ints_ref");
check_set_null_fails(arrays_null.cvar, "arrays_null_bools");
if (arrays_null.arrays_null_globals_check(10) != 1); error("global set to NULL changed it"); endif

if (arrays_null.arrays_null_ints_isnull(null) != 1); error("ints_isnull"); endif
if (arrays_null.arrays_null_ints_unsized_isnull(null) != 1); error("ints_unsized_isnull"); endif
if (arrays_null.arrays_null_enums_isnull(null) != 1); error("enums_isnull"); endif
if (arrays_null.arrays_null_enums_unsized_isnull(null) != 1); error("enums_unsized_isnull"); endif
if (arrays_null.arrays_null_items_isnull(null) != 1); error("items_isnull"); endif
if (arrays_null.arrays_null_items_unsized_isnull(null) != 1); error("items_unsized_isnull"); endif
if (arrays_null.arrays_null_bools_isnull(null) != 1); error("bools_isnull"); endif
if (arrays_null.arrays_null_bools_unsized_isnull(null) != 1); error("bools_unsized_isnull"); endif
if (arrays_null.arrays_null_chars_isnull(null) != 1); error("chars_isnull"); endif
if (arrays_null.arrays_null_chars_unsized_isnull(null) != 1); error("chars_unsized_isnull"); endif
if (arrays_null.arrays_null_strings_isnull(null) != 1); error("strings_isnull"); endif
if (arrays_null.arrays_null_strings_unsized_isnull(null) != 1); error("strings_unsized_isnull"); endif

# A reference to an array cannot be NULL
try
  arrays_null.arrays_null_ints_ref_first(null);
  error("ints_ref_first(null) did not fail");
catch e
  if (isempty(strfind(e.message, "invalid null reference"))); rethrow(e); endif
end_try_catch

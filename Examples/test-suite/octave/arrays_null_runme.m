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
if (arrays_null.arrays_null_globals_check(10) != 1); error("global set to NULL changed it"); endif

if (arrays_null.arrays_null_isnull(null) != 1); error("isnull"); endif

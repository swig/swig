an=require("arrays_null")
catch_undef_globs() -- catch "undefined" global variables

local s = an.ArraysNull()
local other = an.ArraysNull()
an.arrays_null_fill(other, 10)
s.ints = other.ints
s.items = other.items
s.grid = other.grid
assert(an.arrays_null_check(s, 10) == 1)

assert(not pcall(function() s.ints = nil end))
assert(not pcall(function() s.items = nil end))
assert(not pcall(function() s.grid = nil end))
assert(an.arrays_null_check(s, 10) == 1)

an.arrays_null_ints = s.ints
an.arrays_null_items = s.items
an.arrays_null_grid = s.grid
assert(an.arrays_null_globals_check(10) == 1)

assert(not pcall(function() an.arrays_null_ints = nil end))
assert(not pcall(function() an.arrays_null_items = nil end))
assert(not pcall(function() an.arrays_null_grid = nil end))
assert(not pcall(function() an.arrays_null_ints_ref = nil end))
assert(not pcall(function() an.arrays_null_bools = nil end))
assert(an.arrays_null_globals_check(10) == 1)

assert(an.arrays_null_ints_isnull(nil) == 1)
assert(an.arrays_null_ints_unsized_isnull(nil) == 1)
assert(an.arrays_null_enums_isnull(nil) == 1)
assert(an.arrays_null_enums_unsized_isnull(nil) == 1)
assert(an.arrays_null_items_isnull(nil) == 1)
assert(an.arrays_null_items_unsized_isnull(nil) == 1)
assert(an.arrays_null_bools_isnull(nil) == 1)
assert(an.arrays_null_bools_unsized_isnull(nil) == 1)
assert(an.arrays_null_chars_isnull(nil) == 1)
assert(an.arrays_null_chars_unsized_isnull(nil) == 1)
assert(an.arrays_null_strings_isnull(nil) == 1)
assert(an.arrays_null_strings_unsized_isnull(nil) == 1)

-- A reference to an array cannot be nil
assert(not pcall(function() an.arrays_null_ints_ref_first(nil) end))

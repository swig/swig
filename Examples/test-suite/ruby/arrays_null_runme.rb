#!/usr/bin/env ruby

require 'swig_assert'
require 'arrays_null'

def check_nil_rejected(name)
  begin
    yield
    raise RuntimeError, "#{name} set to nil accepted"
  rescue NullReferenceError
  end
end

s = Arrays_null::ArraysNull.new
other = Arrays_null::ArraysNull.new
Arrays_null.arrays_null_fill(other, 10)
s.ints = other.ints
s.items = other.items
s.grid = other.grid
swig_assert_equal('Arrays_null.arrays_null_check(s, 10)', '1', binding)

# Setting an array member or global variable to nil is an error, as there is nothing to copy from.
check_nil_rejected("ints member") { s.ints = nil }
check_nil_rejected("items member") { s.items = nil }
check_nil_rejected("grid member") { s.grid = nil }
swig_assert_equal('Arrays_null.arrays_null_check(s, 10)', '1', binding)

Arrays_null.arrays_null_ints = s.ints
Arrays_null.arrays_null_items = s.items
Arrays_null.arrays_null_grid = s.grid
swig_assert_equal('Arrays_null.arrays_null_globals_check(10)', '1', binding)

check_nil_rejected("ints global") { Arrays_null.arrays_null_ints = nil }
check_nil_rejected("items global") { Arrays_null.arrays_null_items = nil }
check_nil_rejected("grid global") { Arrays_null.arrays_null_grid = nil }
check_nil_rejected("ints_ref global") { Arrays_null.arrays_null_ints_ref = nil }
check_nil_rejected("bools global") { Arrays_null.arrays_null_bools = nil }
swig_assert_equal('Arrays_null.arrays_null_globals_check(10)', '1', binding)

# nil is passed on as a NULL pointer for an array parameter.
swig_assert_equal('Arrays_null.arrays_null_ints_isnull(nil)', '1', binding)
swig_assert_equal('Arrays_null.arrays_null_ints_unsized_isnull(nil)', '1', binding)
swig_assert_equal('Arrays_null.arrays_null_enums_isnull(nil)', '1', binding)
swig_assert_equal('Arrays_null.arrays_null_enums_unsized_isnull(nil)', '1', binding)
swig_assert_equal('Arrays_null.arrays_null_items_isnull(nil)', '1', binding)
swig_assert_equal('Arrays_null.arrays_null_items_unsized_isnull(nil)', '1', binding)
swig_assert_equal('Arrays_null.arrays_null_bools_isnull(nil)', '1', binding)
swig_assert_equal('Arrays_null.arrays_null_bools_unsized_isnull(nil)', '1', binding)
swig_assert_equal('Arrays_null.arrays_null_chars_isnull(nil)', '1', binding)
swig_assert_equal('Arrays_null.arrays_null_chars_unsized_isnull(nil)', '1', binding)
swig_assert_equal('Arrays_null.arrays_null_strings_isnull(nil)', '1', binding)
swig_assert_equal('Arrays_null.arrays_null_strings_unsized_isnull(nil)', '1', binding)

# A reference to an array cannot be nil.
check_nil_rejected("ints_ref parameter") { Arrays_null.arrays_null_ints_ref_first(nil) }

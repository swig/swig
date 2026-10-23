#!/usr/bin/env ruby
#
# Tests the typemaps.i INPUT/OUTPUT/INOUT typemaps

require 'swig_assert'
require 'li_typemaps'

include Li_typemaps

swig_assert_equal_simple(Li_typemaps.in_int(7), 7)
swig_assert_equal_simple(Li_typemaps.inr_int(7), 7)
swig_assert_equal_simple(Li_typemaps.out_int(7), 7)
swig_assert_equal_simple(Li_typemaps.inout_int(7), 7)
swig_assert_equal_simple(Li_typemaps.inoutr_int(7), 7)

# Two parameters using the same typemap
swig_assert_equal_simple(Li_typemaps.in_int_multi(3, 4), 7)
swig_assert_equal_simple(Li_typemaps.out_int_multi(5, 6), [5, 6])
swig_assert_equal_simple(Li_typemaps.inout_int_multi(7, 8), [14, 24])

# A reference cannot be bound to a null pointer, so nil is rejected rather than dereferenced in the call
def check_nullref_rejected(name)
  begin
    yield
  rescue StandardError
    return
  end
  raise "#{name} accepted nil for a reference"
end

check_nullref_rejected('inr_int') { Li_typemaps.inr_int(nil) }
check_nullref_rejected('inoutr_int') { Li_typemaps.inoutr_int(nil) }

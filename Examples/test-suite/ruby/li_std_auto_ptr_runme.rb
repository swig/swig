#!/usr/bin/env ruby

require 'swig_assert'

require 'li_std_auto_ptr'

def gc_check(expected_count)
#  GC.start(full_mark: true, immediate_sweep: true)
  GC.start
# GC is not reliably run, skip check
#  swig_assert_equal_simple(expected_count, Li_std_auto_ptr::Klass::getTotal_count())
end

k1 = Li_std_auto_ptr::makeKlassAutoPtr("first")
k2 = Li_std_auto_ptr::makeKlassAutoPtr("second")
swig_assert_equal_simple(2, Li_std_auto_ptr::Klass::getTotal_count())

gc_check(2)
k1 = nil
gc_check(1)

swig_assert_equal_simple(k2.getLabel(), "second")
gc_check(1)

k2 = nil
gc_check(0)


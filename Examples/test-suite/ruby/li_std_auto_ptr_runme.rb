#!/usr/bin/env ruby

require 'swig_assert'

require 'li_std_auto_ptr'

k1 = Li_std_auto_ptr::makeKlassAutoPtr("first")
k2 = Li_std_auto_ptr::makeKlassAutoPtr("second")
swig_assert_equal_simple(Li_std_auto_ptr::Klass::getTotal_count(), 2)

k1 = nil
GC.start

# GC can need a few runs to actually collect the object.
100.times do ||
  next if Li_std_auto_ptr::Klass::getTotal_count() == 2

  swig_assert_equal_simple(Li_std_auto_ptr::Klass::getTotal_count(), 1)
  break
end

swig_assert_equal_simple(k2.getLabel(), "second")

if Li_std_auto_ptr::Klass::getTotal_count() != 1
  STDERR.puts "GC failed to collect the first object, count still #{Li_std_auto_ptr::Klass::getTotal_count()}"

  # Skip the rest of the test as it's not going to work correctly anyhow.
  exit
end

k2 = nil
GC.start

100.times do ||
  next if Li_std_auto_ptr::Klass::getTotal_count() == 1

  swig_assert_equal_simple(Li_std_auto_ptr::Klass::getTotal_count(), 0)
  break
end

if Li_std_auto_ptr::Klass::getTotal_count() != 0
  STDERR.puts "GC failed to collect the second object, count still #{Li_std_auto_ptr::Klass::getTotal_count()}"
end

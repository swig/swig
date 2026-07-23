#!/usr/bin/env ruby

require 'swig_assert'
require 'char_strings'

CPLUSPLUS_MSG = "A message from the deep dark world of C++, where anything is possible."
OTHERLAND_MSG = "Little message from the safe world."

count = 10

# get functions
count.times do |i|
  swig_assert_equal_simple(Char_strings.GetCharHeapString(), CPLUSPLUS_MSG)
  Char_strings.DeleteCharHeapString()
end

count.times do |i|
  swig_assert_equal_simple(Char_strings.GetConstCharProgramCodeString(), CPLUSPLUS_MSG)
  Char_strings.DeleteCharHeapString()
end

count.times do |i|
  swig_assert_equal_simple(Char_strings.GetCharStaticString(), CPLUSPLUS_MSG)
end

count.times do |i|
  swig_assert_equal_simple(Char_strings.GetCharStaticStringFixed(), CPLUSPLUS_MSG)
end

count.times do |i|
  swig_assert_equal_simple(Char_strings.GetConstCharStaticStringFixed(), CPLUSPLUS_MSG)
end

# set functions
count.times do |i|
  raise "Test char set 1 failed, iteration #{i}" unless Char_strings.SetCharHeapString(OTHERLAND_MSG + i.to_s, i)
end

count.times do |i|
  raise "Test char set 2 failed, iteration #{i}" unless Char_strings.SetCharStaticString(OTHERLAND_MSG + i.to_s, i)
end

count.times do |i|
  raise "Test char set 3 failed, iteration #{i}" unless Char_strings.SetCharArrayStaticString(OTHERLAND_MSG + i.to_s, i)
end

count.times do |i|
  raise "Test char set 4 failed, iteration #{i}" unless Char_strings.SetConstCharHeapString(OTHERLAND_MSG + i.to_s, i)
end

count.times do |i|
  raise "Test char set 5 failed, iteration #{i}" unless Char_strings.SetConstCharStaticString(OTHERLAND_MSG + i.to_s, i)
end

count.times do |i|
  raise "Test char set 6 failed, iteration #{i}" unless Char_strings.SetConstCharArrayStaticString(OTHERLAND_MSG + i.to_s, i)
end

count.times do |i|
  raise "Test char set 7 failed, iteration #{i}" unless Char_strings.SetCharConstStaticString(OTHERLAND_MSG + i.to_s, i)
end

count.times do |i|
  raise "Test char set 8 failed, iteration #{i}" unless Char_strings.SetConstCharConstStaticString(OTHERLAND_MSG + i.to_s, i)
end

count.times do |i|
  raise "Test char set 9 failed, iteration #{i}" unless Char_strings.SetConstCharTypedefString(OTHERLAND_MSG + i.to_s, i)
end

# get set function
count.times do |i|
  ping = OTHERLAND_MSG + i.to_s
  swig_assert_equal_simple(Char_strings.CharPingPong(ping), ping)
end

count.times do |i|
  ping = OTHERLAND_MSG + i.to_s
  swig_assert_equal_simple(Char_strings.CharArrayPingPong(ping), ping)
end

count.times do |i|
  ping = "Ping" + i.to_s  # char[16] buffer, keep short enough to fit
  swig_assert_equal_simple(Char_strings.CharArrayDimsPingPong(ping), ping)
end

# variables
count.times do |i|
  expected = OTHERLAND_MSG + i.to_s
  Char_strings.global_char = expected
  swig_assert_equal_simple(Char_strings.global_char, expected)
end

count.times do |i|
  # global_char_array1 is of type char[] whose varin typemap is undefined
  # (SWIGWARN_TYPEMAP_VARIN_UNDEF), so it is exposed read-only in Ruby and
  # cannot be set. Verify it can still be read (retains its C++ initial value).
  swig_assert_equal_simple(Char_strings.global_char_array1, CPLUSPLUS_MSG)
end

count.times do |i|
  expected = OTHERLAND_MSG + i.to_s
  Char_strings.global_char_array2 = expected
  swig_assert_equal_simple(Char_strings.global_char_array2, expected)
end

count.times do |i|
  swig_assert_equal_simple(Char_strings.global_const_char, CPLUSPLUS_MSG)
end

count.times do |i|
  swig_assert_equal_simple(Char_strings.global_const_char_array1, CPLUSPLUS_MSG)
end

count.times do |i|
  swig_assert_equal_simple(Char_strings.global_const_char_array2, CPLUSPLUS_MSG)
end

# char *& tests
count.times do |i|
  swig_assert_equal_simple(Char_strings.GetCharPointerRef(), CPLUSPLUS_MSG)
end

count.times do |i|
  raise "Test char pointer ref set failed, iteration #{i}" unless Char_strings.SetCharPointerRef(OTHERLAND_MSG + i.to_s, i)
end

count.times do |i|
  swig_assert_equal_simple(Char_strings.GetConstCharPointerRef(), CPLUSPLUS_MSG)
end

count.times do |i|
  raise "Test const char pointer ref set failed, iteration #{i}" unless Char_strings.SetConstCharPointerRef(OTHERLAND_MSG + i.to_s, i)
end

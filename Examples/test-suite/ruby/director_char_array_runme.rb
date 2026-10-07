#!/usr/bin/env ruby

require 'swig_assert'

require 'director_char_array'

class Director < Director_char_array::CharArrayDirector
  def take_array(s)
    s.length
  end
  def take_const_array(s)
    s.length
  end
  def take_array_ref(s)
    s.length
  end
  def take_const_array_ref(s)
    s.length
  end
  def is_null_array(s)
    s.nil? ? 1 : 0
  end
end

d = Director.new
swig_assert_equal_simple(d.call_take_array(), 4)
swig_assert_equal_simple(d.call_take_const_array(), 4)
swig_assert_equal_simple(d.call_take_array_ref(), 4)
swig_assert_equal_simple(d.call_take_const_array_ref(), 4)
swig_assert_equal_simple(d.call_take_array_short(), 2)
swig_assert_equal_simple(d.call_take_array_ref_short(), 2)
swig_assert_equal_simple(d.call_is_null_array(), 1)

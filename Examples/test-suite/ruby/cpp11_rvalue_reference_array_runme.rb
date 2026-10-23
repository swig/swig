#!/usr/bin/env ruby

require 'swig_assert'
require 'cpp11_rvalue_reference_array'

def check_nil_rejected(name)
  begin
    yield
    raise RuntimeError, "#{name} accepted nil"
  rescue NullReferenceError
  end
end

# An rvalue reference to an array is passed as a reference to an array, which cannot be nil.
swig_assert_equal('Cpp11_rvalue_reference_array.sum_of(Cpp11_rvalue_reference_array.others_address)', '100', binding)
swig_assert_equal('Cpp11_rvalue_reference_array.first_of(Cpp11_rvalue_reference_array.others_unsized_address)', '10', binding)
swig_assert_equal('Cpp11_rvalue_reference_array.items_sum(Cpp11_rvalue_reference_array.items_address)', '3', binding)
check_nil_rejected("sum_of") { Cpp11_rvalue_reference_array.sum_of(nil) }
check_nil_rejected("first_of") { Cpp11_rvalue_reference_array.first_of(nil) }

# An rvalue reference to an array of char is a string.
swig_assert_equal('Cpp11_rvalue_reference_array.length_of("abc")', '3', binding)
swig_assert_equal('Cpp11_rvalue_reference_array.length_of_writable("xy")', '2', binding)
check_nil_rejected("length_of") { Cpp11_rvalue_reference_array.length_of(nil) }

# Setting a variable that is an rvalue reference to an array copies into the array it refers to.
swig_assert_equal('Cpp11_rvalue_reference_array.numbers_sum', '10', binding)
Cpp11_rvalue_reference_array.numbers_rref = Cpp11_rvalue_reference_array.others
swig_assert_equal('Cpp11_rvalue_reference_array.numbers_sum', '100', binding)
swig_assert_equal('Cpp11_rvalue_reference_array.letters_rref', "'abc'", binding)
Cpp11_rvalue_reference_array.letters_rref = "xy"
swig_assert_equal('Cpp11_rvalue_reference_array.letters_are', "'xy'", binding)

member = Cpp11_rvalue_reference_array::RvalueRefArrayMember.new
swig_assert_equal('member.sum', '10', binding)
member.member_rref = Cpp11_rvalue_reference_array.others_address
swig_assert_equal('member.sum', '100', binding)
swig_assert_equal('member.text_rref', "'hi'", binding)
member.text_rref = "bye"
swig_assert_equal('member.text_is', "'bye'", binding)

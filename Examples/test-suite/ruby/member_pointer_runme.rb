#!/usr/bin/env ruby
#
# Example using pointers to member functions
# 
# 
#

require 'swig_assert'

require 'member_pointer'

include Member_pointer

def check(what, expected, actual)
  if not expected == actual
    raise RuntimeError, "Failed: #{what} Expected: #{expected} Actual: #{actual}"
  end
end

def check_error(what, error_class)
  begin
    yield
    raise RuntimeError, "#{what} accepted"
  rescue error_class
  end
end

# Get the pointers

area_pt = Member_pointer::areapt
perim_pt = Member_pointer::perimeterpt

# Create some objects

s = Member_pointer::Square.new(10)

# Do some calculations

check "Square area ", 100.0, Member_pointer::do_op(s, area_pt) 
check "Square perim", 40.0, Member_pointer::do_op(s, perim_pt)

memberPtr = Member_pointer::areavar
memberPtr = Member_pointer::perimetervar

# Try the variables
check "Square area ", 100.0, Member_pointer::do_op(s, Member_pointer::areavar)
check "Square perim", 40.0, Member_pointer::do_op(s, Member_pointer::perimetervar)

# Modify one of the variables
Member_pointer::areavar = perim_pt

check "Square perimeter", 40.0, Member_pointer::do_op(s, Member_pointer::areavar)

# Try the constants

memberPtr = Member_pointer::AREAPT
memberPtr = Member_pointer::PERIMPT
memberPtr = Member_pointer::NULLPT

check "Square area ", 100.0, Member_pointer::do_op(s, Member_pointer::AREAPT)
check "Square perim", 40.0, Member_pointer::do_op(s, Member_pointer::PERIMPT)

# Const references to member pointers

check "Square area", 100.0, Member_pointer::do_op_cref(s, area_pt)
check "Square perim", 40.0, Member_pointer::do_op_cref(s, Member_pointer::perimetervar_td_cref)
check "Square perim", 40.0, Member_pointer::do_op(s, Member_pointer::perimetervar_td_cref)
check_error("do_op_cref with ADD_BY_VALUE", TypeError) { Member_pointer::do_op_cref(s, Member_pointer::ADD_BY_VALUE) }

# Overloaded on the member pointer type

check "Overload by value", 3, Member_pointer::call_overloaded(Member_pointer::ADD_BY_VALUE, 1, 2)
check "Overload by pointer", -7, Member_pointer::call_overloaded(Member_pointer::ADD_BY_POINTER, 3, 4)
check "Overload by int", 110, Member_pointer::call_overloaded(10, 5, 6)

# Overloaded on a member pointer and a pointer, only the pointer taking nil

check "Overload by member pointer", 3, Member_pointer::memberpt_or_pointer(Member_pointer::ADD_BY_VALUE)
check "Overload by pointer", 10, Member_pointer::memberpt_or_pointer(Member_pointer::Funktions.new)
check "Overload by nil", 20, Member_pointer::memberpt_or_pointer(nil)

# A string is not a member pointer

check_error("do_op with a string", TypeError) { Member_pointer::do_op(s, "_not_a_member_pointer") }
check_error("memberpt_or_pointer with a string", ArgumentError) { Member_pointer::memberpt_or_pointer("_not_a_member_pointer") }

#!/usr/bin/env ruby

require 'swig_assert'

require 'cpp11_rvalue_reference_move'

# Function containing rvalue reference parameter
Cpp11_rvalue_reference_move::Counter.reset_counts()
mo = Cpp11_rvalue_reference_move::MovableCopyable.new(222)
Cpp11_rvalue_reference_move::Counter.check_counts(1, 0, 0, 0, 0, 0)
Cpp11_rvalue_reference_move::MovableCopyable.movein(mo)
Cpp11_rvalue_reference_move::Counter.check_counts(1, 0, 0, 1, 0, 2)
exception_thrown = false
begin
    Cpp11_rvalue_reference_move::MovableCopyable.is_nullptr(mo)
rescue ObjectPreviouslyDeleted
    exception_thrown = true
end
if (!exception_thrown)
    raise RuntimeError, "is_nullptr failed to throw"
end
mo = nil
Cpp11_rvalue_reference_move::Counter.check_counts(1, 0, 0, 1, 0, 2)

# Move constructor test
Cpp11_rvalue_reference_move::Counter.reset_counts()
mo = Cpp11_rvalue_reference_move::MovableCopyable.new(222)
Cpp11_rvalue_reference_move::Counter.check_counts(1, 0, 0, 0, 0, 0)
mo_moved = Cpp11_rvalue_reference_move::MovableCopyable.new(mo)
Cpp11_rvalue_reference_move::Counter.check_counts(1, 0, 0, 1, 0, 1)
exception_thrown = false
begin
    Cpp11_rvalue_reference_move::MovableCopyable.is_nullptr(mo)
rescue ObjectPreviouslyDeleted
    exception_thrown = true
end
if (!exception_thrown)
    raise RuntimeError, "is_nullptr failed to throw"
end
mo = nil
Cpp11_rvalue_reference_move::Counter.check_counts(1, 0, 0, 1, 0, 1)
# mo_moved = nil
# Cpp11_rvalue_reference_move::Counter.check_counts(1, 0, 0, 1, 0, 2)
# Above not deleting the C++ object(node v12) - can't reliably control GC - use the movein function instead to delete
Cpp11_rvalue_reference_move::MovableCopyable.movein(mo_moved)
Cpp11_rvalue_reference_move::Counter.check_counts(1, 0, 0, 2, 0, 3)

# Move assignment operator test
Cpp11_rvalue_reference_move::Counter.reset_counts()
mo111 = Cpp11_rvalue_reference_move::MovableCopyable.new(111)
mo222 = Cpp11_rvalue_reference_move::MovableCopyable.new(222)
Cpp11_rvalue_reference_move::Counter.check_counts(2, 0, 0, 0, 0, 0)
mo111.MoveAssign(mo222)
Cpp11_rvalue_reference_move::Counter.check_counts(2, 0, 0, 0, 1, 1)
exception_thrown = false
begin
    Cpp11_rvalue_reference_move::MovableCopyable.is_nullptr(mo222)
rescue ObjectPreviouslyDeleted
    exception_thrown = true
end
if (!exception_thrown)
    raise RuntimeError, "is_nullptr failed to throw"
end
mo222 = nil
Cpp11_rvalue_reference_move::Counter.check_counts(2, 0, 0, 0, 1, 1)
# mo111 = nil
# Cpp11_rvalue_reference_move::Counter.check_counts(2, 0, 0, 0, 1, 2)
# Above not deleting the C++ object(node v12) - can't reliably control GC - use the movein function instead to delete
Cpp11_rvalue_reference_move::MovableCopyable.movein(mo111)
Cpp11_rvalue_reference_move::Counter.check_counts(2, 0, 0, 1, 1, 3)

# null check
Cpp11_rvalue_reference_move::Counter.reset_counts()
exception_thrown = false
begin
  Cpp11_rvalue_reference_move::MovableCopyable.movein(nil)
rescue ArgumentError => e
  if (!e.to_s.include? "invalid null reference")
    raise RuntimeError, "incorrect exception message: #{e.to_s}"
  end
  exception_thrown = true
end
if (!exception_thrown)
  raise RuntimeError, "Should have thrown null error"
end
Cpp11_rvalue_reference_move::Counter.check_counts(0, 0, 0, 0, 0, 0)

# output
Cpp11_rvalue_reference_move::Counter.reset_counts()
mc = Cpp11_rvalue_reference_move::MovableCopyable.moveout(1234)
Cpp11_rvalue_reference_move::Counter.check_counts(2, 0, 0, 0, 1, 1)
Cpp11_rvalue_reference_move::MovableCopyable.check_numbers_match(mc, 1234)

exception_thrown = false
begin
  Cpp11_rvalue_reference_move::MovableCopyable.movein(mc)
rescue RuntimeError => e
  if (!e.to_s.include? "cannot release ownership as memory is not owned")
    raise RuntimeError, "incorrect exception message: #{e.to_s}"
  end
  exception_thrown = true
end
if (!exception_thrown)
  raise RuntimeError, "Should have thrown 'Cannot release ownership as memory is not owned' error"
end
Cpp11_rvalue_reference_move::Counter.check_counts(2, 0, 0, 0, 1, 1)

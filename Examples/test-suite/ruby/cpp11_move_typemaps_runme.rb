#!/usr/bin/env ruby

require 'swig_assert'

require 'cpp11_move_typemaps'

Cpp11_move_typemaps::Counter.reset_counts()
mo = Cpp11_move_typemaps::MoveOnly.new(111)
Cpp11_move_typemaps::Counter.check_counts(1, 0, 0, 0, 0, 0)
Cpp11_move_typemaps::MoveOnly.take(mo)
Cpp11_move_typemaps::Counter.check_counts(1, 0, 0, 1, 0, 2)
mo = nil
Cpp11_move_typemaps::Counter.check_counts(1, 0, 0, 1, 0, 2)

Cpp11_move_typemaps::Counter.reset_counts()
mo = Cpp11_move_typemaps::MovableCopyable.new(111)
Cpp11_move_typemaps::Counter.check_counts(1, 0, 0, 0, 0, 0)
Cpp11_move_typemaps::MovableCopyable.take(mo)
Cpp11_move_typemaps::Counter.check_counts(1, 0, 0, 1, 0, 2)
mo = nil
Cpp11_move_typemaps::Counter.check_counts(1, 0, 0, 1, 0, 2)

mo = Cpp11_move_typemaps::MoveOnly.new(222)
Cpp11_move_typemaps::MoveOnly.take(mo)
exception_thrown = false
begin
  Cpp11_move_typemaps::MoveOnly.take(mo)
rescue RuntimeError => e
  if (!e.to_s.include? "cannot release ownership as memory is not owned")
    raise RuntimeError, "incorrect exception message: #{e.to_s}"
  end
  exception_thrown = true
end
if (!exception_thrown)
  raise RuntimeError, "Should have thrown 'Cannot release ownership as memory is not owned' error"
end

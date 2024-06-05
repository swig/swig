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

Cpp11_move_typemaps::Counter.reset_counts()
imt = Cpp11_move_typemaps::InstanceMethodsTester.new()

mo = Cpp11_move_typemaps::MoveOnly.new(333)
Cpp11_move_typemaps::Counter.check_counts(1, 0, 0, 0, 0, 0)
imt.instance_take_move_only(mo)
Cpp11_move_typemaps::Counter.check_counts(1, 0, 0, 1, 0, 2)
mo = nil

Cpp11_move_typemaps::Counter.check_counts(1, 0, 0, 1, 0, 2)
Cpp11_move_typemaps::Counter.reset_counts()

mc = Cpp11_move_typemaps::MovableCopyable.new(444)
Cpp11_move_typemaps::Counter.check_counts(1, 0, 0, 0, 0, 0)
imt.instance_take_movable_copyable(mc)
Cpp11_move_typemaps::Counter.check_counts(1, 0, 0, 1, 0, 2)
mc = nil

Cpp11_move_typemaps::Counter.check_counts(1, 0, 0, 1, 0, 2)

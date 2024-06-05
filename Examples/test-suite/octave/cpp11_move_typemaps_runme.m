# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

cpp11_move_typemaps

Counter.reset_counts();
mo = MoveOnly(111);
Counter.check_counts(1, 0, 0, 0, 0, 0);
MoveOnly.take(mo);
Counter.check_counts(1, 0, 0, 1, 0, 2);
clear mo;
Counter.check_counts(1, 0, 0, 1, 0, 2);

Counter.reset_counts();
mo = MovableCopyable(111);
Counter.check_counts(1, 0, 0, 0, 0, 0);
MovableCopyable.take(mo);
Counter.check_counts(1, 0, 0, 1, 0, 2);
clear mo;
Counter.check_counts(1, 0, 0, 1, 0, 2);

mo = MoveOnly(222);
MoveOnly.take(mo);
exception_thrown = false;
try
  MoveOnly.take(mo);
catch e
  if (isempty(strfind(e.message, "cannot release ownership as memory is not owned")))
    error("incorrect exception message %s", e.message);
  endif
  exception_thrown = true;
end_try_catch
if (!exception_thrown)
    error("double usage of take should have been an error");
endif

Counter.reset_counts();
imt = InstanceMethodsTester();

mo = MoveOnly(333);
Counter.check_counts(1, 0, 0, 0, 0, 0);
imt.instance_take_move_only(mo);
Counter.check_counts(1, 0, 0, 1, 0, 2);
clear mo;

Counter.check_counts(1, 0, 0, 1, 0, 2);
Counter.reset_counts();

mc = MovableCopyable(444);
Counter.check_counts(1, 0, 0, 0, 0, 0);
imt.instance_take_movable_copyable(mc);
Counter.check_counts(1, 0, 0, 1, 0, 2);
clear mc;

Counter.check_counts(1, 0, 0, 1, 0, 2);

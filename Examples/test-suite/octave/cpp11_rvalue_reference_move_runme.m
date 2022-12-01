# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

cpp11_rvalue_reference_move

# Function containing rvalue reference parameter
Counter.reset_counts();
mo = MovableCopyable(222);
Counter.check_counts(1, 0, 0, 0, 0, 0);
MovableCopyable.movein(mo);
Counter.check_counts(1, 0, 0, 1, 0, 2);
if (!MovableCopyable_is_nullptr(mo))
  error("is_nullptr failed");
endif
clear mo;
Counter.check_counts(1, 0, 0, 1, 0, 2);

# Move constructor test
Counter.reset_counts();
mo = MovableCopyable(222);
Counter.check_counts(1, 0, 0, 0, 0, 0);
mo_moved = MovableCopyable(mo);
Counter.check_counts(1, 0, 0, 1, 0, 1);
if (!MovableCopyable_is_nullptr(mo))
  error("is_nullptr failed");
endif
clear mo;
Counter.check_counts(1, 0, 0, 1, 0, 1);
clear mo_moved;
Counter.check_counts(1, 0, 0, 1, 0, 2);

# Move assignment operator test
Counter.reset_counts();
mo111 = MovableCopyable(111);
mo222 = MovableCopyable(222);
Counter.check_counts(2, 0, 0, 0, 0, 0);
mo111.MoveAssign(mo222);
Counter.check_counts(2, 0, 0, 0, 1, 1);
if (!MovableCopyable_is_nullptr(mo222))
  error("is_nullptr failed");
endif
clear mo222;
Counter.check_counts(2, 0, 0, 0, 1, 1);
clear mo111;
Counter.check_counts(2, 0, 0, 0, 1, 2);

# null check
null = []; # NULL pointer
Counter.reset_counts();
exception_thrown = false;
try
  MovableCopyable.movein(null);
catch e
  if (isempty(strfind(e.message, "invalid null reference")))
    error("incorrect exception message: %s", e.message)
  endif
  exception_thrown = true;
end_try_catch
if (!exception_thrown)
  error("Should have thrown null error");
endif
Counter.check_counts(0, 0, 0, 0, 0, 0);


# output
Counter.reset_counts();
mc = MovableCopyable.moveout(1234);
Counter.check_counts(2, 0, 0, 0, 1, 1);
MovableCopyable.check_numbers_match(mc, 1234);

exception_thrown = false;
try
  MovableCopyable.movein(mc);
catch e
  if (isempty(strfind(e.message, "cannot release ownership as memory is not owned")))
    error("incorrect exception message: %s", e.message)
  endif
  exception_thrown = true;
end_try_catch
if (!exception_thrown)
  error("Should have thrown 'Cannot release ownership as memory is not owned' error");
endif
Counter.check_counts(2, 0, 0, 0, 1, 1);

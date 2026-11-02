# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

member_funcptr_galore

function check_type_error(f)
  try
    f();
  catch e
    if (isempty(strfind(e.message, "SWIG_TypeError"))); rethrow(e); endif
    return;
  end_try_catch
  error("%s did not fail", func2str(f));
end

m = MemberFuncPtrs();
if (m.aaa1(cvar.cc1) != 0); error("aaa1"); endif
if (m.aaa6(cvar.cc6) != 0); error("aaa6"); endif
if (m.aaa7(cvar.cc7) != 0); error("aaa7"); endif
if (m.bbb1(cvar.pp1) != 0); error("bbb1"); endif
if (m.bbb6(cvar.pp6) != 0); error("bbb6"); endif
if (m.bbb7(cvar.pp7) != 0); error("bbb7"); endif
if (call1(ADD_BY_VALUE, 1, 2) != 3); error("call1"); endif

# A const reference to a member pointer is passed and returned as the member pointer
if (m.aaa7(cvar.cc1) != 0); error("aaa7 with cc1"); endif
if (m.aaa1(cvar.cc7) != 0); error("aaa1 with cc7"); endif

# A pointer to a non-const member function is not a pointer to a const member function, nor the reverse
check_type_error(@() m.aaa1(cvar.pp1));
check_type_error(@() m.aaa7(cvar.pp7));
check_type_error(@() m.bbb1(cvar.cc1));
check_type_error(@() m.bbb7(cvar.cc7));

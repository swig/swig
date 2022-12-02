# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

catches_strings

exception_thrown = false;
try
  StringsThrower.charstring();
catch e
  if (isempty(strfind(e.message, "charstring message")))
    error("incorrect exception message: %s", e.message)
  endif
  exception_thrown = true;
end_try_catch
if (!exception_thrown)
  error("Should have thrown an exception");
endif

exception_thrown = false;
try
  StringsThrower.stdstring();
catch e
  if (isempty(strfind(e.message, "stdstring message")))
    error("incorrect exception message: %s", e.message)
  endif
  exception_thrown = true;
end_try_catch
if (!exception_thrown)
  error("Should have thrown an exception");
endif

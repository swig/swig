exception_order


a = A();

try
  a.foo()
catch
  if (!strcmp(lasterror.message, "error: C++ side threw an exception of type E1\n"))
    error("bad exception order")
  endif
end_try_catch

try
  a.bar()
catch
  if (!strcmp(lasterror.message, "error: C++ side threw an exception of type E2\n"))
    error("bad exception order")
  endif
end_try_catch

try
  a.foobar()
catch
  if (!strcmp(lasterror.message, "error: postcatch unknown (SWIG_RuntimeError)\n"))
    error("bad exception order")
  endif
end_try_catch

try
  a.barfoo(1)
catch
  if (!strcmp(lasterror.message, "error: C++ side threw an exception of type E1\n"))
    error("bad exception order")
  endif
end_try_catch

try
  a.barfoo(2)
catch
  if (!strcmp(lasterror.message, "error: C++ side threw an exception of type E2 *\n"))
    error("bad exception order")
  endif
end_try_catch

exception_order


a = A();

try
  a.foo()
catch
  if (!strcmp(raised(),"E1"))
    error, "bad exception order"
  endif
end_try_catch

try
  a.bar()
catch
  if (!strcmp(raised(),"E2"))
    error, "bad exception order"
  endif
end_try_catch

try
  a.foobar()
catch
  [t,e]=raised();
  if (!strcmp(e.args(0),"postcatch unknown"))
    error
  endif
end_try_catch

try
  a.barfoo(1)
catch
  if (!strcmp(raised(),"E1"))
    error, "bad exception order"
  endif
end_try_catch

try
  a.barfoo(2)
catch
  if (!strcmp(raised(),"E2"))
    error, "bad exception order"
  endif
end_try_catch

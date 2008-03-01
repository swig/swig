director_exception

MyFoo=@() subclass(Foo(),
		   'ping',@(self) raise(NotImplementedError("MyFoo::ping() EXCEPTION")));

MyFoo2=@() subclass(Foo(),
		    'ping',@(self) true);
		   
ok = 0;

a = MyFoo();
b = launder(a);

try
  b.pong();
catch
  [etype,e]=raised();
  if (etype=="NotImplementedError")
    ok=1;
  endif
end_try_catch

if (!ok)
  error
endif

ok = 0;

a = MyFoo2();
b = launder(a);

try
  b.pong();
catch
  ok = 1;
end_try_catch

if (!ok)
  error
endif


try
  raise(Exception2());
catch
  if (!strcmp(raised,"Exception2"))
    rethrow(lasterr);
  endif
end_try_catch

try
  raise(Exception1());
catch
  if (!strcmp(raised,"Exception1"))
    rethrow(lasterr);
  endif
end_try_catch

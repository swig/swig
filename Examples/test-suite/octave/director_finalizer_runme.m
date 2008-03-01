director_finalizer

MyFoo=@() subclass(Foo(),'__del__',@delete_MyFoo);
function delete_MyFoo(self)
  self.orStatus(2);
  try
    Foo.__del__(self);
  catch
  end_try_catch
endfunction

resetStatus();

a = MyFoo();
clear a;

if (getStatus() != 3)
  error
endif

resetStatus();

a = MyFoo();
launder(a);

if (getStatus() != 0)
  error
endif

clear a;

if (getStatus() != 3)
  error
endif

resetStatus();

a = MyFoo().__disown__();
deleteFoo(a);

if (getStatus() != 3)
  error
endif

resetStatus();

a = MyFoo().__disown__();
deleteFoo(launder(a));

if (getStatus() != 3)
  error
endif

resetStatus();



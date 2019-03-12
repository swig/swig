open Swig
open Newobject2

let _ =
  assert (_fooCount '() as int = 0);
  let foo1 = _makeFoo '() in
  assert (_fooCount '() as int = 1);
  assert (_do_stuff '(foo1) = C_void);
  let foo2 = _makeFoo '() in
  assert (_fooCount '() as int = 2);
  assert (_do_stuff '(foo2) = C_void);
  ignore (foo1 -> "~" ());
  assert (_fooCount '() as int = 1);
  ignore (foo2 -> "~" ());
  assert (_fooCount '() as int = 0)
;;

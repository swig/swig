open Swig
open Template_default_arg

let _ =
  let helloInt = new_Hello_int '() and enumArg = _hi '() in
  assert (helloInt -> foo (enumArg) = C_void);
  assert (helloInt -> foo () = C_void);

  let x = new_X_int '() in
  assert (x -> meth (20.0, 200) as int = 200);
  assert (x -> meth (20) as int = 20);
  assert (x -> meth () as int = 0);

  let x = new_Y_unsigned '() in
  let args = C_list [ C_double 20.0 ; C_uint 200l ] in
  assert (x -> meth (args) as int = 200);
  let args = C_uint 20l in
  assert (x -> meth (args) as int = 20);
  assert (x -> meth () as int = 0);

  let x = new_X_longlong '() in
  assert (x -> meth (20.0) as int = 0);
  let x = new_X_longlong '(20.0) in
  assert (x -> meth (20.0) as int = 0);
  let args = C_list [ C_double 20.0 ; C_int64 200L ] in
  let x = new_X_longlong '(args) in
  assert (x -> meth (20.0) as int = 0);

  let x = new_X_int '() in
  assert (x -> meth (20.0) as int = 0);
  let x = new_X_int '(20.0) in
  assert (x -> meth (20.0) as int = 0);
  let x = new_X_int '(20.0, 200) in
  assert (x -> meth (20.0) as int = 0);

  let arg = new_Foo_int '() in
  assert (_ott '(arg) as int = 30);
  assert (_ott '() as int = 10);
  assert (_ott '(1) as int = 10);
  assert (_ott '(1, 1) as int = 10);
  assert (_ott '("hi") as int = 20);
  assert (_ott '("hi", 1) as int = 20);
  assert (_ott '("hi", 1, 1) as int = 20);

  let arg = new_Hello_int '() in
  assert (_ottstring '(arg, "hi") as int = 40);
  assert (_ottstring '(arg) as int = 40);
  assert (_ottint '(arg, 1) as int = 50);
  assert (_ottint '(arg) as int = 50);
  assert (_ott '(arg, 1.0) as int = 60);
  assert (_ott '(arg) as int = 60);
;;

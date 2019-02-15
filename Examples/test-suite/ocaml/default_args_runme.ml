open Swig
open Default_args

let _ =
  assert (_anonymous '() as int = 7771);
  assert (_anonymous '(1234) as int = 1234);
  assert (_booltest '() as bool = true);
  assert (_booltest '(true) as bool = true);
  assert (_booltest '(false) as bool = false);
  let ec = new_EnumClass '() in
  assert (ec -> blah () as bool = true);
  let de = new_DerivedEnumClass '() in
  assert (de -> accelerate () = C_void);
  let args = _SLOW '() in
  assert (de -> accelerate (args) = C_void);
  assert (_Statics_staticmethod '() as int = 60);
  assert (_cfunc1 '(1) as float = 2.);
  assert (_cfunc2 '(1) as float = 3.);
  assert (_cfunc3 '(1) as float = 4.);

  let f = new_Foo '() in
  assert (f -> newname () = C_void);
  assert (f -> newname (1) = C_void);
  (* TODO: There needs to be a more elegant way to pass NULL/nullptr. *)
  let args = C_list [ C_int 2 ; C_ptr (0L, 0L) ] in
  assert (f -> double_if_void_ptr_is_null (args) as int = 4);
  assert (f -> double_if_void_ptr_is_null (3) as int = 6);
  let args = C_list [ C_int 4 ; C_ptr (0L, 0L) ] in
  assert (f -> double_if_handle_is_null (args) as int = 8);
  assert (f -> double_if_handle_is_null (5) as int = 10);
  let args = C_list [ C_int 6 ; C_ptr (0L, 0L) ] in
  assert (f -> double_if_dbl_ptr_is_null (args) as int = 12);
  assert (f -> double_if_dbl_ptr_is_null (7) as int = 14);

  let k = new_Klass '(22) in
  let k2 = _Klass_inc (C_list [ C_int 100 ; k ]) in
  assert (k2 -> "[val]" () as int = 122);
  let k2 = _Klass_inc '(100) in
  assert (k2 -> "[val]" () as int = 99);
  let k2 = _Klass_inc '() in
  assert (k2 -> "[val]" () as int = 0);

  assert (_seek '() = C_void);
  assert (_seek (C_int64 10L) = C_void);

  assert (_slightly_off_square '(10) as int = 102);
  assert (_slightly_off_square '() as int = 291);

  assert (_casts1 '() as char = '\x00');
  assert (_casts2 '() as string = "Hello");
  assert (_casts1 '("Ciao") as string = "Ciao");
  assert (_chartest1 '() as char = 'x');
  assert (_chartest2 '() as char = '\x00');
  assert (_chartest3 '() as char = '\x01');
  assert (_chartest4 '() as char = '\n');
  assert (_chartest5 '() as char = 'B');
  assert (_chartest6 '() as char = 'C');
;;

open Swig
open Typedef_mptr

let _ =
  let f = new_Foo '() in
  let args = C_list [ C_int 2 ; C_int 1 ; _add '() ] in
  assert (f -> do_op (args) as int = 3);
  let args = C_list [ C_int 2 ; C_int 1 ; _sub '() ] in
  assert (f -> do_op (args) as int = 1);

  assert (_do_op (C_list [ f ; C_int 2 ; C_int 1 ; _add '() ]) = C_int 3);
  assert (_do_op (C_list [ f ; C_int 2 ; C_int 1 ; _sub '() ]) = C_int 1);
;;

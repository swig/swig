open Swig
open Cpp_enum

let _ =
  let f = new_Foo '() in
  assert ((f -> "[hola]" ()) as int = 1);
  ignore (f -> "[hola]" (0));
  assert ((f -> "[hola]" ()) as int = 0);
  ignore (_hi (C_int 1));
  assert (_hi '() as int = 1);
  ignore (_hi (C_int 0));
  assert (_hi '() as int = 0)
;;

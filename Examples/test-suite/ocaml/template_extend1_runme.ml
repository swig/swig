open Swig
open Template_extend1

let _ =
  let a = new_lBaz '() and b = new_dBaz '() in
  assert (a -> foo () as string = "lBaz::foo");
  assert (b -> foo () as string = "dBaz::foo")
;;

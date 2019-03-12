open Swig
open Overload_subtype

let _ =
  let f = new_Foo '() and b = new_Bar '() in
  assert (_spam (f) as int = 1);
  assert (_spam (b) as int = 2)
;;

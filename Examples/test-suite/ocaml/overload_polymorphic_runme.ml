open Swig
open Overload_polymorphic

let _ =
  let t = new_Derived '() in
  assert (_test (t) as int = 0);
  assert (_test '(1) as int = 1);
  assert (_test2 (t) as int = 1)
;;

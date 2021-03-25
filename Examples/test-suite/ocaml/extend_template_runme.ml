open Swig
open Extend_template

let f = new_Foo_0 '()
let _ =
  assert((f -> "test1" (37) as int) = 37);
  assert((f -> "test2" (42) as int) = 42);
;;

open Swig
open Overload_extend

let _ =
  let f = new_Foo '() in
  assert (f -> test () as int = 0);
  assert (f -> test (3) as int = 1);
  assert (f -> test ("hello") as int = 2);
  assert (f -> test (3., 2.) as float = 5.);
  assert (f -> test (3.) as float = 1003.)
;;

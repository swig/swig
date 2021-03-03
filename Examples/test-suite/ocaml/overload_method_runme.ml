open Swig
open Overload_method

let _ =
  let b = new_Base '() in
  assert (b -> "method" () as int = 42);
  assert (b -> "overloaded_method" () as int = 42);
  assert (b -> "overloaded_method" (5) = C_void);
  assert (b -> "overloaded_method" () as int = 5);
  assert (b -> "method" () as int = 5);
;;

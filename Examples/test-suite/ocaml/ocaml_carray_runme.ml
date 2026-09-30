open Swig
open Ocaml_carray

let _ =
  let ints = C_array (Array.init 8 (fun i -> C_int (i + 1))) in
  assert (_sum_ints ints as int = 36);
  let doubles = C_array [| C_double 0.5; C_double 1.5; C_double 2.5; C_double 3.5 |] in
  assert (_sum_doubles doubles as float = 8.)
;;

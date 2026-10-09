open Swig
open Ocaml_carray

let _ =
  let ints = C_array (Array.init 8 (fun i -> C_int (i + 1))) in
  assert (_sum_ints ints as int = 36);
  let doubles = C_array [| C_double 0.5; C_double 1.5; C_double 2.5; C_double 3.5 |] in
  assert (_sum_doubles doubles as float = 8.);
  let schars = C_array [| C_int (-1); C_int 2; C_int (-3); C_int 4 |] in
  assert (_sum_schars schars as int = 2);
  let uchars = C_array [| C_int 200; C_int 50; C_int 1; C_int 4 |] in
  assert (_sum_uchars uchars as int = 255);
  (* C_void is passed as NULL for an array parameter *)
  assert (_sum_ints (C_list [ C_void ]) as int = -1);
  assert (_sum_doubles (C_list [ C_void ]) as float = -1.);
  assert (_sum_items (C_list [ C_void ]) as int = -1);
  (* Setting an array member variable to C_void raises an error, as there is nothing to copy from *)
  let m = new_CarrayMember '() in
  ignore ((invoke m) "[ints]" ints);
  assert (try ignore ((invoke m) "[ints]" (C_list [ C_void ])); false with Invalid_argument _ -> true);
  assert (_sum_ints ((invoke m) "[ints]" C_void) as int = 36)
;;

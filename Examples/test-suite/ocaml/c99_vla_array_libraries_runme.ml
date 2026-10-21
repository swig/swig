open Swig
open C99_vla_array_libraries

let _ =
  let ints = C_array [| C_int 1; C_int 2; C_int 3 |] in
  assert (_sum_ints (C_list [ C_int 3; ints ]) as int = 6);
  (* Only as many elements as the size given at runtime are copied *)
  assert (_sum_ints (C_list [ C_int 2; ints ]) as int = 3);
  let doubles = C_array [| C_double 0.5; C_double 1.5 |] in
  assert (_sum_doubles (C_list [ C_int 2; doubles ]) as float = 2.)
;;

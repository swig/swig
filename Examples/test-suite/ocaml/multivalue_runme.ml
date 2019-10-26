open Swig
open Multivalue

let _ =
  assert (_divide_l '(37, 5) = C_list ['7;'2]);
  assert (_divide_v '(41, 7) = C_list ['5;'6]);
  assert (_divide_mv '(91, 13) = C_list ['7;'0]);
;;

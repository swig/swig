open Swig
open Multichar_constant

let _ =
  (* Multicharacter constants have type int, not char. *)
  assert ((_MULTICHAR_AB '() as int) = (_imulti_ab '() as int));
;;

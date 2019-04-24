open Swig
open Types_directive

let _ =
  (* Check that a Time1 instance is accepted where a Date instance is expected. *)
  let d1 = new_Time1 '(2001, 2, 3, 60) in
  let newDate = _add '(d1, 7) in
  assert (newDate -> "[day]" () as int = 10);

  (* Check that a Time2 instance is accepted where a Date instance is expected. *)
  let d2 = new_Time2 '(1999, 8, 7, 60) in
  let newDate = _add '(d2, 7) in
  assert (newDate -> "[day]" () as int = 14)
;;

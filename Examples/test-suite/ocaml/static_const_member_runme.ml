open Swig
open Static_const_member

let _ =
  assert (_X_PN '() as int = 0);
  assert (_X_CN '() as int = 1);
  assert (_X_EN '() as int = 2);
  assert (_X_CHARTEST '() as char = 'A');
;;

open Swig
open Li_cpointer_cpp

let _ =
  let p = _new_intp '() in
  assert (_intp_value '(p) as int = 0);
  assert (_intp_assign '(p, 3) = C_void);
  assert (_intp_value '(p) as int = 3);
  assert (_delete_intp '(p) = C_void)
;;

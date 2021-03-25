open Swig
open Typedef_reference

let _ =
  let i = _copy_intp '(2) in
  assert (_somefunc '(i) as int = 2);
  assert (_delete_intp '(i) = C_void);
  let i = _copy_intp '(3) in
  assert (_otherfunc '(i) as int = 3);
  assert (_delete_intp '(i) = C_void);
;;

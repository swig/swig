open Swig
open Default_arg_values

let _ =
  let d = new_Display '() in
  assert (d -> draw1 () as float = 0.);
  let arg = C_float 12. in
  assert (d -> draw1 (arg) as float = 12.);
  let arg = C_float 123. in
  let p = _createPtr '(arg) in
  assert (d -> draw2 () as float = 0.);
  assert (d -> draw2 (p) as float = 123.);
  assert (d -> bool0 () as bool = false);
  assert (d -> bool1 () as bool = true);
  assert (d -> mybool0 () as bool = false);
  assert (d -> mybool1 () as bool = true)
;;

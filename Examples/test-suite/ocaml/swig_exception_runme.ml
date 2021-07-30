open Swig
open Swig_exception

let _ =
  let c = new_Circle '(10) and s = new_Square '(10) in
  assert (_Shape_nshapes '() as int = 2);
  try
    ignore (c -> throwException ()); assert false
  with Sys_error msg -> assert (msg = "OK");
  let _ = c -> "~" () in
  let _ = s -> "~" () in
  assert (_Shape_nshapes '() as int = 0);
;;

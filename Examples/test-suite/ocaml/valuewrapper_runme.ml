open Swig
open Valuewrapper

let _ =
  let x1 = new_Xi '(5) and y1 = new_YXi '() in
  assert (y1 -> spam (x1) as int = 0);
  assert (y1 -> spam () as int = 0)
;;

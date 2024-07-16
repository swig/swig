open Swig
open Li_cdata

let _ =
  let s = "ABC\x20abc" in
  let m = _malloc '(256) in
  let _ = _memmove '(m, (C_string s)) in
  let ss = _cdata '(m, 7) as string in
  assert (ss = "ABC abc");
;;

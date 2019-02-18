open Swig
open Sizet

let _ =
  let s = C_int64 2000L in
  assert (_test1 '(s) as int = 2000);
  assert (_test2 '(s) as int = 2000);
  assert (_test3 '(s) as int = 2000);
  assert (_test4 '(s) as int = 2000);
;;

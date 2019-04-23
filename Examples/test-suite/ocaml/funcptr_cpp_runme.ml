open Swig
open Funcptr_cpp

let _ =
  let fp = _ADD_BY_VALUE '() in
  assert (_call1 '(fp, 10, 11) as int = 21);
  let fp = _ADD_BY_POINTER '() in
  assert (_call2 '(fp, 12, 13) as int = 25);
  let fp = _ADD_BY_REFERENCE '() in
  assert (_call3 '(fp, 14, 15) as int = 29);
  let fp = _ADD_BY_VALUE_C '() in
  assert (_call1 '(fp, 2, 3) as int = 5);
;;

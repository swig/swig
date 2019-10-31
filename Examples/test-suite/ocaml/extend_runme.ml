open Swig
open Extend

let _ =
  let base1 = new_Base '() and base2 = new_Base '(10) in
  assert ((base1 -> "[value]" () as int) = 0);
  assert ((base2 -> "[value]" () as int) = 10);
  let cint = C_int 5 in
  assert ((base1 -> "method" (cint) as int) = 5);
  assert ((_Base_zeroVal '() as int) = 0);
  assert ((base2 -> "currentValue" () as int) = 10);
  let cint = C_int 7 in
  assert ((base2 -> "extendmethod" (cint) as int) = 14);
;;

let _ =
  let der1 = new_Derived '(0) and der2 = new_Derived '(17) in
  assert ((der1 -> "[value]" () as int) = 0);
  let cint = C_int 5 in
  assert ((der1 -> "method" (cint) as int) = 10);
  assert ((der2 -> "[value]" () as int) = 34);
  let cfloat = C_float 200. in
  ignore (der2 -> "[extendval]" (cfloat));
  assert (abs_float ((der2 -> "[actualval]" () as float) -. 2.) < 0.001);
  assert (abs_float ((der2 -> "[extendval]" () as float) -. 200.) < 0.001);
;;

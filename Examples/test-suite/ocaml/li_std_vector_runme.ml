open Swig
open Li_std_vector

let _ =
  let iv = new_IntVector '() in
  assert (iv -> "empty" () as bool);
  assert ((iv -> "size" () as int) = 0);
  ignore (iv -> "push_back" (123));
  assert ((iv -> "empty" () as bool) = false);
  assert ((iv -> "size" () as int) = 1);
  assert ((iv -> "[]" (0) as int) = 123);
  ignore (iv -> "clear" ());
  assert (iv -> "empty" () as bool);
  assert ((iv -> "size" () as int) = 0);
;;

let _ =
  let rv = new_RealVector '() in
  ignore (rv -> "push_back" (100.));
  ignore (rv -> "push_back" (200.));
  assert ((rv -> "[]" (0) as float) = 100.);
  assert ((rv -> "[]" (1) as float) = 200.);
;;

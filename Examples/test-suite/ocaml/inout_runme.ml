open Swig
open Inout

let _ =
  assert (_AddOne1 '(1.) as float = 2.);
  assert (_AddOne3 '(1, 1, 1) = C_list ['2.;'2.;'2.]);
  assert (_AddOne1r '(1.) as float = 2.);
;;

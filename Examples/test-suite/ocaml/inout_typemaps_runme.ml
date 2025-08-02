open Swig
open Inout_typemaps

let _ =
  assert (_AddOne1 '(1.) as float = 2.);
  assert (_AddOne3 '(10, 20, 30) = C_list ['11.;'21.;'31.]);
  assert (_AddOne1r '(20.) as float = 21.);
;;

open Swig
open Director_unroll

let director_unroll_MyFoo ob meth args =
  match meth with
    | "ping" -> C_string "director_unroll_MyFoo::ping()"
    | _ -> (invoke ob) meth args

let a =
  new_derived_object
    new_Foo (director_unroll_MyFoo) '()

let _ =
  let b = new_Bar '() in
  let _ = b -> set (a) in
  let c = b -> get () in
  assert (director_unroll_MyFoo c "ping" '() as string =
    "director_unroll_MyFoo::ping()");
;;

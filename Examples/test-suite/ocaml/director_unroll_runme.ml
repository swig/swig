open Swig
open Director_unroll

let director_unroll_MyFoo ob meth args =
  match meth with
    | "ping" -> C_string "MyFoo::ping()"
    | _ -> (invoke ob) meth args

let a = new_derived_object
  new_Foo (director_unroll_MyFoo) '()

let b = new_Bar '()
let _ = b -> set (a)
let c = b -> get ()
let _ = assert ((a -> "&" () as int) = (c -> "&" () as int))
